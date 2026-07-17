#!/usr/bin/env python3

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
import uuid


SCHEMA = "skill-eval/v1"
REPO_ROOT = Path(__file__).resolve().parents[1]
SKILL_SCOPES = ("global-skills", "project-skills", "general-skills")


class CaseValidationError(ValueError):
    pass


def positive_int(value: str) -> int:
    parsed = int(value)
    if parsed < 1:
        raise argparse.ArgumentTypeError("must be at least 1")
    return parsed


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run isolated, repeated skill-routing eval cases."
    )
    parser.add_argument(
        "--cases",
        required=True,
        type=Path,
        help="A skill-eval JSON file or a directory containing JSON suites.",
    )
    parser.add_argument(
        "--adapter",
        help="Executable that reads a prompt JSON object and writes activation JSON.",
    )
    parser.add_argument(
        "--runs",
        type=positive_int,
        default=3,
        help="Independent trials per case (default: 3).",
    )
    parser.add_argument(
        "--timeout-seconds",
        type=positive_int,
        default=300,
        help="Timeout for each adapter invocation (default: 300).",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=REPO_ROOT / "evals" / "results",
        help="Generated result directory (default: evals/results).",
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Validate case files without invoking an adapter or writing results.",
    )
    args = parser.parse_args()
    if not args.validate_only and not args.adapter:
        parser.error("--adapter is required unless --validate-only is used")
    return args


def require_nonempty_string(value: object, label: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise CaseValidationError(f"{label} must be a non-empty string")
    return value


def require_skill_list(value: object, label: str) -> list[str]:
    if not isinstance(value, list) or not all(
        isinstance(item, str) and item.strip() for item in value
    ):
        raise CaseValidationError(f"{label} must be a list of non-empty strings")
    if len(value) != len(set(value)):
        raise CaseValidationError(f"{label} must not contain duplicates")
    return value


def case_files(path: Path) -> list[Path]:
    if path.is_file():
        return [path]
    if path.is_dir():
        files = sorted(path.glob("*.json"))
        if files:
            return files
        raise CaseValidationError(f"no JSON case files found in {path}")
    raise CaseValidationError(f"case path does not exist: {path}")


def load_cases(path: Path) -> tuple[list[dict[str, object]], int]:
    loaded_cases: list[dict[str, object]] = []
    seen_suites: set[str] = set()

    for source in case_files(path):
        try:
            document = json.loads(source.read_text())
        except (OSError, json.JSONDecodeError) as error:
            raise CaseValidationError(f"cannot read {source}: {error}") from error

        if not isinstance(document, dict):
            raise CaseValidationError(f"{source}: root must be an object")
        if document.get("$schema") != SCHEMA:
            raise CaseValidationError(f"{source}: $schema must be {SCHEMA!r}")

        suite = require_nonempty_string(document.get("suite"), f"{source}: suite")
        if suite in seen_suites:
            raise CaseValidationError(f"duplicate suite name: {suite}")
        seen_suites.add(suite)

        raw_cases = document.get("cases")
        if not isinstance(raw_cases, list) or not raw_cases:
            raise CaseValidationError(f"{source}: cases must be a non-empty list")

        seen_case_ids: set[str] = set()
        for index, raw_case in enumerate(raw_cases, start=1):
            label = f"{source}: cases[{index}]"
            if not isinstance(raw_case, dict):
                raise CaseValidationError(f"{label} must be an object")

            case_id = require_nonempty_string(raw_case.get("id"), f"{label}.id")
            if case_id in seen_case_ids:
                raise CaseValidationError(f"{source}: duplicate case id: {case_id}")
            seen_case_ids.add(case_id)

            prompt = require_nonempty_string(raw_case.get("prompt"), f"{label}.prompt")
            expect = raw_case.get("expect")
            if not isinstance(expect, dict):
                raise CaseValidationError(f"{label}.expect must be an object")
            activate = require_skill_list(expect.get("activate"), f"{label}.expect.activate")
            not_activate = require_skill_list(
                expect.get("not_activate"), f"{label}.expect.not_activate"
            )
            overlap = sorted(set(activate) & set(not_activate))
            if overlap:
                raise CaseValidationError(
                    f"{label}: skills cannot be both required and forbidden: {overlap}"
                )
            if not activate and not not_activate:
                raise CaseValidationError(f"{label}: at least one expectation is required")

            loaded_cases.append(
                {
                    "suite": suite,
                    "source": str(source),
                    "id": case_id,
                    "prompt": prompt,
                    "activate": activate,
                    "not_activate": not_activate,
                }
            )

    return loaded_cases, len(seen_suites)


def resolve_adapter(value: str) -> str:
    candidate = Path(value).expanduser()
    if candidate.is_file():
        return str(candidate.resolve())
    resolved = shutil.which(value)
    if resolved:
        return resolved
    raise CaseValidationError(f"adapter executable not found: {value}")


def adapter_failure(
    case: dict[str, object],
    iteration: int,
    message: str,
    *,
    stdout: str = "",
    stderr: str = "",
) -> dict[str, object]:
    return {
        "suite": case["suite"],
        "case_id": case["id"],
        "iteration": iteration,
        "passed": False,
        "activated_skills": [],
        "missing_skills": case["activate"],
        "forbidden_activated_skills": [],
        "response": "",
        "adapter_error": message,
        "adapter_stdout": stdout,
        "adapter_stderr": stderr,
    }


def captured_text(value: str | bytes | None) -> str:
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    return value or ""


def stop_process_tree(
    process: subprocess.Popen[str],
) -> tuple[str, str]:
    if os.name == "posix":
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    else:
        process.terminate()

    try:
        stdout, stderr = process.communicate(timeout=5)
    except subprocess.TimeoutExpired:
        if os.name == "posix":
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
        else:
            process.kill()
        stdout, stderr = process.communicate()
    return captured_text(stdout), captured_text(stderr)


def copy_skill_bundle(workspace: Path) -> Path:
    bundle = workspace / "skill-sources"
    for scope in SKILL_SCOPES:
        source_scope = REPO_ROOT / scope
        target_scope = bundle / scope
        target_scope.mkdir(parents=True, exist_ok=True)
        for skill_dir in sorted(source_scope.iterdir()):
            if skill_dir.is_dir() and (skill_dir / "SKILL.md").is_file():
                shutil.copytree(
                    skill_dir,
                    target_scope / skill_dir.name,
                    ignore=shutil.ignore_patterns("__pycache__"),
                )
    return bundle


def run_trial(
    case: dict[str, object], adapter: str, iteration: int, timeout_seconds: int
) -> dict[str, object]:
    request = json.dumps({"prompt": case["prompt"]}, ensure_ascii=False)
    run_id = uuid.uuid4().hex

    try:
        with tempfile.TemporaryDirectory(prefix="skill-eval-") as workspace:
            workspace_path = Path(workspace)
            skills_dir = copy_skill_bundle(workspace_path)
            env = os.environ.copy()
            env.pop("OLDPWD", None)
            env.pop("SKILL_EVAL_REPO_ROOT", None)
            env["PWD"] = workspace
            env["SKILL_EVAL_RUN_ID"] = run_id
            env["SKILL_EVAL_SKILLS_DIR"] = str(skills_dir)
            process = subprocess.Popen(
                [adapter],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                cwd=workspace,
                env=env,
                start_new_session=os.name == "posix",
            )
            try:
                stdout, stderr = process.communicate(request, timeout=timeout_seconds)
            except subprocess.TimeoutExpired:
                stdout, stderr = stop_process_tree(process)
                return adapter_failure(
                    case,
                    iteration,
                    f"adapter timed out after {timeout_seconds} seconds",
                    stdout=stdout,
                    stderr=stderr,
                )
    except OSError as error:
        return adapter_failure(case, iteration, f"could not execute adapter: {error}")

    if process.returncode != 0:
        return adapter_failure(
            case,
            iteration,
            f"adapter exited with status {process.returncode}",
            stdout=stdout,
            stderr=stderr,
        )

    try:
        output = json.loads(stdout)
        if not isinstance(output, dict):
            raise ValueError("root must be an object")
        activated = require_skill_list(
            output.get("activated_skills"), "adapter activated_skills"
        )
        response = output.get("response", "")
        if not isinstance(response, str):
            raise ValueError("response must be a string when present")
    except (json.JSONDecodeError, CaseValidationError, ValueError) as error:
        return adapter_failure(
            case,
            iteration,
            f"invalid adapter output: {error}",
            stdout=stdout,
            stderr=stderr,
        )

    missing = sorted(set(case["activate"]) - set(activated))
    forbidden = sorted(set(case["not_activate"]) & set(activated))
    return {
        "suite": case["suite"],
        "case_id": case["id"],
        "iteration": iteration,
        "passed": not missing and not forbidden,
        "activated_skills": activated,
        "missing_skills": missing,
        "forbidden_activated_skills": forbidden,
        "response": response,
        "adapter_error": "",
        "adapter_stdout": "",
        "adapter_stderr": stderr,
    }


def write_results(
    output_dir: Path,
    cases: list[dict[str, object]],
    runs: list[dict[str, object]],
    runs_per_case: int,
    adapter: str,
    started_at: str,
) -> tuple[Path, dict[str, int]]:
    case_passes = {
        (case["suite"], case["id"]): True
        for case in cases
    }
    for run in runs:
        key = (run["suite"], run["case_id"])
        case_passes[key] = case_passes[key] and bool(run["passed"])

    summary = {
        "cases": len(cases),
        "passed_cases": sum(case_passes.values()),
        "runs": len(runs),
        "passed_runs": sum(bool(run["passed"]) for run in runs),
    }
    finished_at = datetime.now(timezone.utc)
    artifact = {
        "$schema": "skill-eval-result/v1",
        "started_at": started_at,
        "finished_at": finished_at.isoformat(),
        "adapter": adapter,
        "runs_per_case": runs_per_case,
        "summary": summary,
        "runs": runs,
    }

    output_dir.mkdir(parents=True, exist_ok=True)
    filename = finished_at.strftime("%Y%m%dT%H%M%S%fZ.json")
    result_path = output_dir / filename
    result_path.write_text(json.dumps(artifact, ensure_ascii=False, indent=2) + "\n")
    return result_path, summary


def main() -> int:
    args = parse_args()
    try:
        cases, suite_count = load_cases(args.cases)
        if args.validate_only:
            noun = "suite" if suite_count == 1 else "suites"
            print(f"Validated {len(cases)} cases from {suite_count} {noun}.")
            return 0
        adapter = resolve_adapter(args.adapter)
    except CaseValidationError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2

    started_at = datetime.now(timezone.utc).isoformat()
    runs = [
        run_trial(case, adapter, iteration, args.timeout_seconds)
        for case in cases
        for iteration in range(1, args.runs + 1)
    ]
    result_path, summary = write_results(
        args.output_dir,
        cases,
        runs,
        args.runs,
        adapter,
        started_at,
    )
    print(
        f"{summary['passed_runs']}/{summary['runs']} runs passed "
        f"({summary['passed_cases']}/{summary['cases']} cases)."
    )
    print(f"Results: {result_path}")
    return 0 if summary["passed_runs"] == summary["runs"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
