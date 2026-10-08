#!/usr/bin/env python3

import json
import sys


request = json.load(sys.stdin)
if set(request["candidates"]) != {"A", "B"}:
    raise SystemExit("judge expected anonymized candidates A and B")
if any("arm" in candidate for candidate in request["candidates"].values()):
    raise SystemExit("arm label leaked to the judge")

ran = {
    label: any("pytest" in line for line in candidate["transcript"])
    for label, candidate in request["candidates"].items()
}
preferred = "tie" if ran["A"] == ran["B"] else ("A" if ran["A"] else "B")
json.dump(
    {"preferred": preferred, "criteria": {label: [value] * len(request["rubric"]) for label, value in ran.items()}},
    sys.stdout,
)
