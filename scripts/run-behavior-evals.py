#!/usr/bin/env python3

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import importlib.util
import json
import os
from pathlib import Path
import random
import re
import shutil
import subprocess
import sys
import tempfile
import uuid


SCHEMA = "skill-behavior-eval/v1"
REPO_ROOT = Path(__file__).resolve().parents[1]
ARMS = ("with", "without")
TEXT_CHECKS = {
    "response_matches": ("response", True),
    "response_not_matches": ("response", False),
    "transcript_matches": ("transcript", True),
    "transcript_not_matches": ("transcript", False),
}
FILE_CHECKS = {"file_exists", "file_matches"}

_spec = importlib.util.spec_from_file_location(
    "run_skill_evals", Path(__file__).with_name("run-skill-evals.py")
)
routing = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(routing)
CaseValidationError = routing.CaseValidationError
require_nonempty_string = routing.require_nonempty_string
require_skill_list = routing.require_skill_list


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run isolated skill behavior evals with and without the skills under test."
    )
    parser.add_argument("--cases", required=True, type=Path, help="A behavior JSON file or directory.")
    parser.add_argument("--adapter", help="Executable that runs one fresh agent invocation.")
    parser.add_argument("--judge", help="Optional executable that grades anonymized candidate pairs.")
    parser.add_argument("--runs", type=routing.positive_int, default=3, help="Trials per arm (default: 3).")
    parser.add_argument(
        "--arms",
        choices=("both", "with"),
        default="both",
        help="Run the baseline arm too (default) or only the arm with the skills.",
    )
    parser.add_argument("--timeout-seconds", type=routing.positive_int, default=600)
    parser.add_argument("--output-dir", type=Path, default=REPO_ROOT / "evals" / "results")
    parser.add_argument("--seed", type=int, help="Seed for judge candidate order.")
    parser.add_argument("--validate-only", action="store_true")
    args = parser.parse_args()
    if not args.validate_only and not args.adapter:
        parser.error("--adapter is required unless --validate-only is used")
    if args.judge and args.arms != "both":
        parser.error("--judge compares both arms; use --arms both")
    return args


def available_skills() -> set[str]:
    return {
        path.parent.name
        for scope in routing.SKILL_SCOPES
        for path in (REPO_ROOT / scope).glob("*/SKILL.md")
    }


def load_check(raw: object, label: str) -> dict[str, object]:
    if not isinstance(raw, dict):
        raise CaseValidationError(f"{label} must be an object")
    check_id = require_nonempty_string(raw.get("id"), f"{label}.id")
    kind = raw.get("type")
    if kind in TEXT_CHECKS:
        pattern = require_nonempty_string(raw.get("pattern"), f"{label}.pattern")
        try:
            re.compile(pattern)
        except re.error as error:
            raise CaseValidationError(f"{label}.pattern is not a valid regex: {error}") from error
        return {"id": check_id, "type": kind, "pattern": pattern}
    if kind in FILE_CHECKS:
        path = require_nonempty_string(raw.get("path"), f"{label}.path")
        if Path(path).is_absolute() or ".." in Path(path).parts:
            raise CaseValidationError(f"{label}.path must stay inside the project directory")
        check = {"id": check_id, "type": kind, "path": path}
        if kind == "file_matches":
            pattern = require_nonempty_string(raw.get("pattern"), f"{label}.pattern")
            try:
                re.compile(pattern)
            except re.error as error:
                raise CaseValidationError(f"{label}.pattern is not a valid regex: {error}") from error
            check["pattern"] = pattern
        return check
    raise CaseValidationError(f"{label}.type must be one of {sorted([*TEXT_CHECKS, *FILE_CHECKS])}")


def load_cases(path: Path) -> tuple[list[dict[str, object]], int]:
    known_skills = available_skills()
    loaded: list[dict[str, object]] = []
    seen_suites: set[str] = set()
    for source in routing.case_files(path):
        try:
            document = json.loads(source.read_text())
        except (OSError, json.JSONDecodeError) as error:
            raise CaseValidationError(f"cannot read {source}: {error}") from error
        if not isinstance(document, dict) or document.get("$schema") != SCHEMA:
            raise CaseValidationError(f"{source}: $schema must be {SCHEMA!r}")
        suite = require_nonempty_string(document.get("suite"), f"{source}: suite")
        if suite in seen_suites:
            raise CaseValidationError(f"duplicate suite name: {suite}")
        seen_suites.add(suite)
        raw_cases = document.get("cases")
        if not isinstance(raw_cases, list) or not raw_cases:
            raise CaseValidationError(f"{source}: cases must be a non-empty list")

        seen_ids: set[str] = set()
        for index, raw in enumerate(raw_cases, start=1):
            label = f"{source}: cases[{index}]"
            if not isinstance(raw, dict):
                raise CaseValidationError(f"{label} must be an object")
            case_id = require_nonempty_string(raw.get("id"), f"{label}.id")
            if case_id in seen_ids:
                raise CaseValidationError(f"{source}: duplicate case id: {case_id}")
            seen_ids.add(case_id)
            skills = require_skill_list(raw.get("skills_under_test"), f"{label}.skills_under_test")
            if not skills:
                raise CaseValidationError(f"{label}.skills_under_test must not be empty")
            unknown = sorted(set(skills) - known_skills)
            if unknown:
                raise CaseValidationError(f"{label}: unknown skills_under_test: {unknown}")
            raw_checks = raw.get("checks")
            if not isinstance(raw_checks, list) or not raw_checks:
                raise CaseValidationError(f"{label}.checks must be a non-empty list")
            checks = [load_check(c, f"{label}.checks[{i}]") for i, c in enumerate(raw_checks, start=1)]
            if len({c["id"] for c in checks}) != len(checks):
                raise CaseValidationError(f"{label}: duplicate check id")
            rubric = raw.get("rubric", [])
            if not isinstance(rubric, list) or not all(isinstance(r, str) and r.strip() for r in rubric):
                raise CaseValidationError(f"{label}.rubric must be a list of non-empty strings")
            fixture = None
            if "fixture" in raw:
                fixture = (source.parent / require_nonempty_string(raw["fixture"], f"{label}.fixture")).resolve()
                if not fixture.is_dir():
                    raise CaseValidationError(f"{label}.fixture is not a directory: {fixture}")
            loaded.append(
                {
                    "suite": suite,
                    "id": case_id,
                    "prompt": require_nonempty_string(raw.get("prompt"), f"{label}.prompt"),
                    "skills_under_test": skills,
                    "checks": checks,
                    "rubric": rubric,
                    "fixture": fixture,
                }
            )
    return loaded, len(seen_suites)


def require_transcript(value: object) -> list[str]:
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise ValueError("transcript must be a list of strings")
    return value


def evaluate_checks(
    checks: list[dict[str, object]], response: str, transcript: list[str], project: Path
) -> dict[str, bool]:
    texts = {"response": response, "transcript": "\n".join(transcript)}
    results: dict[str, bool] = {}
    for check in checks:
        kind = check["type"]
        if kind in TEXT_CHECKS:
            field, should_match = TEXT_CHECKS[kind]
            found = re.search(check["pattern"], texts[field], re.MULTILINE) is not None
            results[check["id"]] = found == should_match
        else:
            target = project / check["path"]
            if kind == "file_exists":
                results[check["id"]] = target.is_file()
            else:
                results[check["id"]] = target.is_file() and re.search(
                    check["pattern"], target.read_text(errors="replace"), re.MULTILINE
                ) is not None
    return results


def run_trial(
    case: dict[str, object], arm: str, adapter: str, iteration: int, timeout_seconds: int
) -> dict[str, object]:
    record = {
        "suite": case["suite"],
        "case_id": case["id"],
        "arm": arm,
        "iteration": iteration,
        "passed": False,
        "checks": {},
        "activated_skills": [],
        "response": "",
        "transcript": [],
        "adapter_error": "",
        "adapter_stderr": "",
    }
    request = json.dumps({"prompt": case["prompt"]}, ensure_ascii=False)
    with tempfile.TemporaryDirectory(prefix="skill-behavior-eval-") as workspace:
        workspace_path = Path(workspace)
        skills_dir = routing.copy_skill_bundle(workspace_path)
        if arm == "without":
            for scope in routing.SKILL_SCOPES:
                for name in case["skills_under_test"]:
                    shutil.rmtree(skills_dir / scope / name, ignore_errors=True)
        project = workspace_path / "project"
        if case["fixture"]:
            shutil.copytree(case["fixture"], project)
        else:
            project.mkdir()
        env = os.environ.copy()
        env.pop("OLDPWD", None)
        env.pop("SKILL_EVAL_REPO_ROOT", None)
        env["PWD"] = str(project)
        env["SKILL_EVAL_RUN_ID"] = uuid.uuid4().hex
        env["SKILL_EVAL_SKILLS_DIR"] = str(skills_dir)
        try:
            process = subprocess.Popen(
                [adapter],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                cwd=project,
                env=env,
                start_new_session=os.name == "posix",
            )
        except OSError as error:
            record["adapter_error"] = f"could not execute adapter: {error}"
            return record
        try:
            stdout, stderr = process.communicate(request, timeout=timeout_seconds)
        except subprocess.TimeoutExpired:
            _, stderr = routing.stop_process_tree(process)
            record["adapter_error"] = f"adapter timed out after {timeout_seconds} seconds"
            record["adapter_stderr"] = stderr
            return record
        record["adapter_stderr"] = stderr
        if process.returncode != 0:
            record["adapter_error"] = f"adapter exited with status {process.returncode}"
            return record
        try:
            output = json.loads(stdout)
            if not isinstance(output, dict):
                raise ValueError("root must be an object")
            response = output.get("response", "")
            if not isinstance(response, str):
                raise ValueError("response must be a string")
            transcript = require_transcript(output.get("transcript"))
            activated = require_skill_list(output.get("activated_skills", []), "activated_skills")
        except (json.JSONDecodeError, CaseValidationError, ValueError) as error:
            record["adapter_error"] = f"invalid adapter output: {error}"
            return record
        checks = evaluate_checks(case["checks"], response, transcript, project)
    record.update(
        passed=all(checks.values()),
        checks=checks,
        activated_skills=activated,
        response=response,
        transcript=transcript,
    )
    return record


def judge_pair(
    case: dict[str, object],
    with_run: dict[str, object],
    without_run: dict[str, object],
    judge: str,
    rng: random.Random,
    timeout_seconds: int,
) -> dict[str, object]:
    labels = ["A", "B"]
    rng.shuffle(labels)
    mapping = {labels[0]: "with", labels[1]: "without"}
    runs = {"with": with_run, "without": without_run}
    request = {
        "prompt": case["prompt"],
        "rubric": case["rubric"],
        "candidates": {
            label: {"response": runs[arm]["response"], "transcript": runs[arm]["transcript"]}
            for label, arm in sorted(mapping.items())
        },
    }
    record = {"case_id": case["id"], "iteration": with_run["iteration"], "error": ""}
    try:
        completed = subprocess.run(
            [judge],
            input=json.dumps(request, ensure_ascii=False),
            capture_output=True,
            text=True,
            timeout=timeout_seconds,
        )
        if completed.returncode != 0:
            raise ValueError(f"judge exited with status {completed.returncode}")
        output = json.loads(completed.stdout)
        preferred = output.get("preferred")
        if preferred not in ("A", "B", "tie"):
            raise ValueError("preferred must be A, B, or tie")
        criteria = output.get("criteria")
        if not isinstance(criteria, dict) or set(criteria) != {"A", "B"}:
            raise ValueError("criteria must have keys A and B")
        for label in ("A", "B"):
            values = criteria[label]
            if not isinstance(values, list) or len(values) != len(case["rubric"]) or not all(
                isinstance(v, bool) for v in values
            ):
                raise ValueError("each criteria list must hold one boolean per rubric item")
    except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError, ValueError) as error:
        record["error"] = f"judge failed: {error}"
        return record
    record["preferred"] = "tie" if preferred == "tie" else mapping[preferred]
    record["criteria"] = {mapping[label]: criteria[label] for label in ("A", "B")}
    return record


def summarize(
    cases: list[dict[str, object]], runs: list[dict[str, object]], verdicts: list[dict[str, object]]
) -> dict[str, object]:
    arms = sorted({run["arm"] for run in runs}, key=ARMS.index)
    summary: dict[str, object] = {"cases": len(cases), "arms": {}}
    for arm in arms:
        arm_runs = [run for run in runs if run["arm"] == arm]
        summary["arms"][arm] = {
            "runs": len(arm_runs),
            "passed_runs": sum(run["passed"] for run in arm_runs),
            "adapter_errors": sum(bool(run["adapter_error"]) for run in arm_runs),
        }
    if verdicts:
        graded = [v for v in verdicts if not v["error"]]
        summary["judge"] = {
            "pairs": len(verdicts),
            "errors": len(verdicts) - len(graded),
            "preferred_with": sum(v["preferred"] == "with" for v in graded),
            "preferred_without": sum(v["preferred"] == "without" for v in graded),
            "ties": sum(v["preferred"] == "tie" for v in graded),
        }
    return summary


def main() -> int:
    args = parse_args()
    try:
        cases, suite_count = load_cases(args.cases)
        if args.validate_only:
            noun = "suite" if suite_count == 1 else "suites"
            print(f"Validated {len(cases)} behavior cases from {suite_count} {noun}.")
            return 0
        adapter = routing.resolve_adapter(args.adapter)
        judge = routing.resolve_adapter(args.judge) if args.judge else None
    except CaseValidationError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2

    started_at = datetime.now(timezone.utc).isoformat()
    arms = ARMS if args.arms == "both" else ("with",)
    runs = [
        run_trial(case, arm, adapter, iteration, args.timeout_seconds)
        for case in cases
        for iteration in range(1, args.runs + 1)
        for arm in arms
    ]
    verdicts: list[dict[str, object]] = []
    if judge:
        rng = random.Random(args.seed)
        by_key = {(r["case_id"], r["arm"], r["iteration"]): r for r in runs}
        for case in cases:
            if not case["rubric"]:
                continue
            for iteration in range(1, args.runs + 1):
                pair = (by_key[(case["id"], "with", iteration)], by_key[(case["id"], "without", iteration)])
                if any(run["adapter_error"] for run in pair):
                    continue
                verdicts.append(judge_pair(case, *pair, judge, rng, args.timeout_seconds))

    summary = summarize(cases, runs, verdicts)
    finished_at = datetime.now(timezone.utc)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    result_path = args.output_dir / finished_at.strftime("behavior-%Y%m%dT%H%M%S%fZ.json")
    artifact = {
        "$schema": "skill-behavior-eval-result/v1",
        "started_at": started_at,
        "finished_at": finished_at.isoformat(),
        "adapter": adapter,
        "judge": judge,
        "runs_per_arm": args.runs,
        "summary": summary,
        "runs": runs,
        "verdicts": verdicts,
    }
    result_path.write_text(json.dumps(artifact, ensure_ascii=False, indent=2) + "\n")

    for arm, stats in summary["arms"].items():
        print(f"{arm}: {stats['passed_runs']}/{stats['runs']} runs passed all checks.")
    if "judge" in summary:
        j = summary["judge"]
        print(
            f"judge: with {j['preferred_with']}, without {j['preferred_without']}, "
            f"tie {j['ties']}, errors {j['errors']}."
        )
    print(f"Results: {result_path}")
    with_stats = summary["arms"]["with"]
    return 0 if with_stats["passed_runs"] == with_stats["runs"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
