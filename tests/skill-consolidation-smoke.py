#!/usr/bin/env python3
"""Verify fresh installs contain the consolidated skills and their references."""

from pathlib import Path
import os
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
RETIRED = {
    "--global": ("grill-with-docs", "project-structure-advisor", "repository-boundary-review"),
    "--project": ("better-useeffect",),
}
PROVIDERS = {
    "opencode": (".config/opencode/skills", ".opencode/skills"),
    "codex": (".agents/skills", ".agents/skills"),
    "claude": (".claude/skills", ".claude/skills"),
    "gemini": (".gemini/config/skills", ".agents/skills"),
    "pi": (".agents/skills", ".agents/skills"),
}


class PackageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="skill-consolidation-")
        self.addCleanup(self.temp.cleanup)

    def run_setup(self, scope, provider):
        command = [str(ROOT / "setup.sh"), provider, "install", "skills", scope]
        if scope == "--project":
            command.extend(["--target", str(self.project)])
        return subprocess.run(command, cwd=self.project, env={**os.environ, "HOME": str(self.home)},
                              capture_output=True, text=True)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_all_providers_copy_complete_consolidated_packages(self):
        # Each provider gets a fresh home/project, including providers sharing paths.
        for provider, paths in PROVIDERS.items():
            with self.subTest(provider=provider):
                self.home = Path(self.temp.name) / provider / "home"
                self.project = Path(self.temp.name) / provider / "project"
                self.home.mkdir(parents=True)
                self.project.mkdir()
                for scope, source_dir, base, relative in (
                    ("--global", "global-skills", self.home, paths[0]),
                    ("--project", "project-skills", self.project, paths[1]),
                ):
                    self.assert_success(self.run_setup(scope, provider))
                    source = ROOT / source_dir
                    installed = base / relative
                    expected = {"grilling", "module-boundaries"} if scope == "--global" else {"frontend-patterns"}
                    discovered = {p.name for p in installed.iterdir()}
                    self.assertTrue(expected.issubset(discovered))
                    self.assertFalse(discovered.intersection(RETIRED[scope]))
                    for name in expected:
                        source_files = {p.relative_to(source / name): p.read_bytes()
                                        for p in (source / name).rglob("*") if p.is_file()}
                        installed_files = {p.relative_to(installed / name): p.read_bytes()
                                           for p in (installed / name).rglob("*") if p.is_file()}
                        self.assertEqual(installed_files, source_files, name)


if __name__ == "__main__":
    unittest.main()
