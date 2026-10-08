#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
import json
import time

import new_parser
import old_parser

payload = json.dumps({"rows": [{"id": i, "name": f"row-{i}", "tags": ["a", "b"]} for i in range(2000)]})
for name, module in (("old", old_parser), ("new", new_parser)):
    start = time.perf_counter()
    for _ in range(200):
        module.parse(payload)
    print(f"{name}: {(time.perf_counter() - start) * 1000:.1f} ms")
PY
