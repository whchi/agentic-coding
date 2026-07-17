#!/usr/bin/env python3

import json
import os
from pathlib import Path
import subprocess
import sys
import time


request = json.load(sys.stdin)
if set(request) != {"prompt"}:
    raise SystemExit("adapter received fields other than prompt")

repo_root = Path(__file__).resolve().parents[3]
for key in ("PWD", "OLDPWD", "SKILL_EVAL_REPO_ROOT"):
    if str(repo_root) in os.environ.get(key, ""):
        raise SystemExit(f"repository path leaked through {key}")

skills_dir_value = os.environ.get("SKILL_EVAL_SKILLS_DIR")
if not skills_dir_value:
    raise SystemExit("adapter did not receive an isolated skill bundle")
skills_dir = Path(skills_dir_value)
if not (skills_dir / "global-skills" / "debugging-playbook" / "SKILL.md").is_file():
    raise SystemExit("isolated skill bundle is incomplete")
if any(path.name in {"evals", "results"} for path in skills_dir.rglob("*")):
    raise SystemExit("eval expectations leaked into the skill bundle")

marker = Path(".adapter-ran")
if marker.exists():
    raise SystemExit("workspace was reused")
marker.write_text("ran\n")

if request["prompt"] == "Timeout probe":
    child_marker = os.environ.get("SKILL_EVAL_TEST_CHILD_MARKER")
    if child_marker:
        subprocess.Popen(
            [
                sys.executable,
                "-c",
                (
                    "import pathlib,sys,time;"
                    "time.sleep(2);"
                    "pathlib.Path(sys.argv[1]).write_text('orphaned\\n')"
                ),
                child_marker,
            ]
        )
    sys.stdout.write("partial output")
    sys.stdout.flush()
    time.sleep(5)

activated_skills = []
if "Find sources" in request["prompt"]:
    activated_skills.append("super-google-search")

json.dump(
    {
        "activated_skills": activated_skills,
        "response": str(Path.cwd()),
    },
    sys.stdout,
)
