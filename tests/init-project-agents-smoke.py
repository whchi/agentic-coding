#!/usr/bin/env python3
"""Exercise initializer IO and failure handling without a live model call."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InitializerSmoke(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="agents-init-test-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.repo = self.base / "project with spaces"
        self.repo.mkdir()
        subprocess.run(["git", "init", "-q", str(self.repo)], check=True)
        self.dest = self.repo / "AGENTS.md"
        self.bin = self.base / "bin"
        self.bin.mkdir()
        fake = self.bin / "codex"
        fake.write_text('''#!/usr/bin/env python3
import os, pathlib, sys
args = sys.argv[1:]
assert args[0] == "exec"
assert args[args.index("--sandbox") + 1] == "read-only"
assert pathlib.Path(args[args.index("--cd") + 1]).resolve() == pathlib.Path(os.environ["TEST_REPO"]).resolve()
prompt = sys.stdin.read()
assert "Reference standard:" in prompt
assert "writing-a-good-claude-md" in prompt
pathlib.Path(os.environ["TEST_CALLED"]).write_text(prompt)
mode = os.environ.get("TEST_MODE", "normal")
if mode == "fail": sys.exit(7)
if mode == "concurrent":
    (pathlib.Path(os.environ["TEST_REPO"]) / "AGENTS.md").write_text("user edit\\n")
out = pathlib.Path(args[args.index("--output-last-message") + 1])
out.write_text("BLOCKED: missing evidence\\n" if mode == "blocked" else "# AGENTS.md\\n\\nProject guidance.\\n")
''')
        fake.chmod(0o755)
        self.env = dict(os.environ, PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
                        TMPDIR=str(self.base), TEST_REPO=str(self.repo),
                        TEST_CALLED=str(self.base / "called"))

    def run_init(self, *args, mode="normal"):
        return subprocess.run(["bash", str(ROOT / "init-project-agents.sh"), *args],
                              env=dict(self.env, TEST_MODE=mode), text=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def test_create_and_idempotence(self):
        result = self.run_init("--target", str(self.repo))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.dest.read_text(), "# AGENTS.md\n\nProject guidance.\n")
        before = self.dest.stat().st_mtime_ns
        result = self.run_init("--target", str(self.repo))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Already consistent", result.stdout)
        self.assertEqual(self.dest.stat().st_mtime_ns, before)

    def test_update_retains_original(self):
        self.dest.write_text("# Existing guidance\n")
        result = self.run_init("--target", str(self.repo))
        self.assertEqual(result.returncode, 0, result.stderr)
        backups = list(self.base.glob("project-agents.*/AGENTS.before.md"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "# Existing guidance\n")

    def test_failures_preserve_existing(self):
        for mode in ("fail", "blocked", "concurrent"):
            with self.subTest(mode=mode):
                self.dest.write_text("original\n")
                result = self.run_init("--target", str(self.repo), mode=mode)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.dest.read_text(), "user edit\n" if mode == "concurrent" else "original\n")

    def test_dry_run_does_not_invoke_model(self):
        result = self.run_init("--target", str(self.repo), "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("writing-a-good-claude-md", result.stdout)
        self.assertFalse(self.dest.exists())
        self.assertFalse((self.base / "called").exists())

    def test_invalid_targets(self):
        subdir = self.repo / "src"
        subdir.mkdir()
        for args in ([], ["--target"], ["--target", str(self.base)],
                     ["--target", str(subdir)], ["--target", str(ROOT)]):
            with self.subTest(args=args):
                self.assertNotEqual(self.run_init(*args).returncode, 0)
        outside = self.base / "global.md"
        outside.write_text("global rules\n")
        self.dest.symlink_to(outside)
        self.assertNotEqual(self.run_init("--target", str(self.repo)).returncode, 0)
        self.assertEqual(outside.read_text(), "global rules\n")


if __name__ == "__main__":
    unittest.main()
