#!/usr/bin/env python3

import json
import os
from pathlib import Path
import sys


request = json.load(sys.stdin)
if set(request) != {"prompt"}:
    raise SystemExit("adapter received fields other than prompt")

skills_dir = Path(os.environ["SKILL_EVAL_SKILLS_DIR"])
project = Path.cwd()
if not (project / "app.py").is_file():
    raise SystemExit("fixture was not copied into the project directory")
for path in [*project.rglob("*"), *skills_dir.rglob("*")]:
    if path.name in {"cases.json", "evals", "results"}:
        raise SystemExit(f"eval expectations leaked: {path}")

has_skill = (skills_dir / "global-skills" / "debugging-playbook" / "SKILL.md").is_file()
if has_skill:
    (project / "REPORT.md").write_text("Cause: off-by-one index in last_item.\n")
    transcript = ["tool: bash python -m pytest -k last_item", "result: 1 failed (IndexError)"]
else:
    transcript = ["tool: read app.py"]

json.dump(
    {
        "activated_skills": ["debugging-playbook"] if has_skill else [],
        "response": "Root cause confirmed by repro.",
        "transcript": transcript,
    },
    sys.stdout,
)
