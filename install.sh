#!/usr/bin/env bash
#
# install.sh — Install skills and commands from this repo into OpenCode directories.
#
# Usage:
#   ./install.sh                                    # interactive menu
#   ./install.sh skills --global                    # install all global skills
#   ./install.sh skills --project                   # install all project skills
#   ./install.sh skills --global api-design         # install one global skill
#   ./install.sh skills --project frontend-patterns # install one project skill
#   ./install.sh commands --global                  # install all global commands
#   ./install.sh commands --project                 # install all project commands
#   ./install.sh commands --global tdd              # install one global command
#   ./install.sh all --global                       # install all global skills + commands
#   ./install.sh all --project                      # install all project skills + commands
#
# Global installs → ~/.config/opencode/
# Project installs → .opencode/ (current working directory)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL_SKILLS_DIR="$HOME/.config/opencode/skills"
GLOBAL_COMMANDS_DIR="$HOME/.config/opencode/commands"
PROJECT_SKILLS_DIR=".opencode/skills"
PROJECT_COMMANDS_DIR=".opencode/commands"

# ── helpers ──────────────────────────────────────────────────────────────────

die() { echo "error: $*" >&2; exit 1; }

ensure_dir() { mkdir -p "$1"; }

install_dir() {
  local src="$1" dest="$2"
  echo "  → $src → $dest"
  rm -rf "$dest"
  cp -R "$src" "$dest"
}

install_file() {
  local src="$1" dest="$2"
  echo "  → $src → $dest"
  cp -f "$src" "$dest"
}

# ── skills ───────────────────────────────────────────────────────────────────

GLOBAL_SKILLS=(
  api-design
  better-test-driven-development
  content-engine
  docker-patterns
  edit-article
  grill-me
  iterative-retrieval
  write-a-prd
)

PROJECT_SKILLS=(
  better-useeffect
  database-migrations
  frontend-patterns
  frontend-slides
  js-ts-coding-standards
  pure-function-pattern
  skill-creator
)

install_skills() {
  local scope="$1" name="$2"

  if [[ "$scope" == "--global" ]]; then
    ensure_dir "$GLOBAL_SKILLS_DIR"
    if [[ -n "$name" ]]; then
      install_dir "$SCRIPT_DIR/global-skills/$name" "$GLOBAL_SKILLS_DIR/$name"
    else
      for s in "${GLOBAL_SKILLS[@]}"; do
        install_dir "$SCRIPT_DIR/global-skills/$s" "$GLOBAL_SKILLS_DIR/$s"
      done
    fi
  elif [[ "$scope" == "--project" ]]; then
    ensure_dir "$PROJECT_SKILLS_DIR"
    if [[ -n "$name" ]]; then
      install_dir "$SCRIPT_DIR/project-skills/$name" "$PROJECT_SKILLS_DIR/$name"
    else
      for s in "${PROJECT_SKILLS[@]}"; do
        install_dir "$SCRIPT_DIR/project-skills/$s" "$PROJECT_SKILLS_DIR/$s"
      done
    fi
  else
    die "skills requires --global or --project"
  fi
}

# ── commands ─────────────────────────────────────────────────────────────────

COMMANDS=(
  anthropic-skill-review
  build-fix
  code-review
  learn
  tdd
  update-codemaps
)

install_commands() {
  local scope="$1" name="$2"

  if [[ "$scope" == "--global" ]]; then
    ensure_dir "$GLOBAL_COMMANDS_DIR"
    if [[ -n "$name" ]]; then
      install_file "$SCRIPT_DIR/commands/$name.md" "$GLOBAL_COMMANDS_DIR/$name.md"
    else
      for c in "${COMMANDS[@]}"; do
        install_file "$SCRIPT_DIR/commands/$c.md" "$GLOBAL_COMMANDS_DIR/$c.md"
      done
    fi
  elif [[ "$scope" == "--project" ]]; then
    ensure_dir "$PROJECT_COMMANDS_DIR"
    if [[ -n "$name" ]]; then
      install_file "$SCRIPT_DIR/commands/$name.md" "$PROJECT_COMMANDS_DIR/$name.md"
    else
      for c in "${COMMANDS[@]}"; do
        install_file "$SCRIPT_DIR/commands/$c.md" "$PROJECT_COMMANDS_DIR/$c.md"
      done
    fi
  else
    die "commands requires --global or --project"
  fi
}

# ── interactive menu ─────────────────────────────────────────────────────────

menu() {
  echo "agentic-coding installer"
  echo ""
  echo "  Skills (global):"
  for s in "${GLOBAL_SKILLS[@]}"; do echo "    $s"; done
  echo ""
  echo "  Skills (project):"
  for s in "${PROJECT_SKILLS[@]}"; do echo "    $s"; done
  echo ""
  echo "  Commands:"
  for c in "${COMMANDS[@]}"; do echo "    $c"; done
  echo ""
  echo "Run with arguments to install directly, e.g.:"
  echo "  ./install.sh skills --global"
  echo "  ./install.sh skills --project frontend-patterns"
  echo "  ./install.sh commands --global tdd"
  echo "  ./install.sh all --global"
}

# ── main ─────────────────────────────────────────────────────────────────────

case "${1:-menu}" in
  skills)      install_skills "${2:-}" "${3:-}" ;;
  commands)    install_commands "${2:-}" "${3:-}" ;;
  all)
    install_skills "${2:-}" ""
    install_commands "${2:-}" ""
    ;;
  *)           menu ;;
esac
