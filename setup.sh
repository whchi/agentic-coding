#!/usr/bin/env bash
#
# setup.sh - Install, reinstall, or uninstall skills and commands from this repo.
#
# Usage:
#   ./setup.sh opencode                             # menu
#   ./setup.sh codex                                # menu
#   ./setup.sh opencode install skills --global     # install all global skills
#   ./setup.sh codex reinstall all --global         # reinstall all global skills + commands
#   ./setup.sh opencode uninstall commands --project mock-or-not
#
# OpenCode global installs -> ~/.config/opencode/
# OpenCode project installs -> .opencode/ (current working directory)
# Codex global installs -> ~/.codex/
# Codex project installs -> .codex/ (current working directory)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROVIDER="${1:-}"

if [[ "$PROVIDER" != "opencode" && "$PROVIDER" != "codex" ]]; then
  echo "error: provider is required: opencode or codex" >&2
  echo "" >&2
  echo "Usage: ./setup.sh <opencode|codex> [install|reinstall|uninstall] [skills|commands|all] [--global|--project] [name]" >&2
  exit 1
fi

shift
ACTION="${1:-menu}"
if [[ "$ACTION" == "install" || "$ACTION" == "reinstall" || "$ACTION" == "uninstall" ]]; then
  shift
elif [[ "$ACTION" != "menu" ]]; then
  echo "error: unknown action: $ACTION (expected install, reinstall, uninstall)" >&2
  exit 1
fi

if [[ "$PROVIDER" == "opencode" ]]; then
  GLOBAL_SKILLS_DIR="$HOME/.config/opencode/skills"
  GLOBAL_COMMANDS_DIR="$HOME/.config/opencode/commands"
  PROJECT_SKILLS_DIR=".opencode/skills"
  PROJECT_COMMANDS_DIR=".opencode/commands"
else
  GLOBAL_SKILLS_DIR="$HOME/.codex/skills"
  GLOBAL_COMMANDS_DIR="$HOME/.codex/prompts"
  PROJECT_SKILLS_DIR=".codex/skills"
  PROJECT_COMMANDS_DIR=".codex/prompts"
fi

# ── helpers ──────────────────────────────────────────────────────────────────

die() { echo "error: $*" >&2; exit 1; }

ensure_dir() { mkdir -p "$1"; }

contains_item() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

require_known_item() {
  local kind="$1" name="$2"
  shift 2
  contains_item "$name" "$@" && return 0
  die "unknown $kind: $name (available: $*)"
}

install_dir() {
  local src="$1" dest="$2"
  [[ ! -e "$dest" ]] || die "already exists: $dest (use reinstall)"
  echo "  install $src → $dest"
  cp -R "$src" "$dest"
}

reinstall_dir() {
  local src="$1" dest="$2"
  echo "  reinstall $src → $dest"
  rm -rf "$dest"
  cp -R "$src" "$dest"
}

uninstall_path() {
  local dest="$1"
  if [[ -e "$dest" ]]; then
    echo "  uninstall $dest"
    rm -rf "$dest"
  else
    echo "  skip missing $dest"
  fi
}

install_file() {
  local src="$1" dest="$2"
  [[ ! -e "$dest" ]] || die "already exists: $dest (use reinstall)"
  echo "  install $src → $dest"
  cp -f "$src" "$dest"
}

reinstall_file() {
  local src="$1" dest="$2"
  echo "  reinstall $src → $dest"
  rm -f "$dest"
  cp -f "$src" "$dest"
}

# ── skills ───────────────────────────────────────────────────────────────────

GLOBAL_SKILLS=(
  api-design
  better-test-driven-development
  content-engine
  debugging-playbook
  domain-driven-design-advisor
  edit-article
  frontend-slides
  grill-me
  grill-with-docs
  handoff
  iterative-retrieval
  maintainable-code-review
  planning-with-files
  product-engineering-mvp
  project-structure-advisor
  repository-boundary-review
  testing-strategy
  write-a-skill
  write-a-prd
  zoom-out
)

PROJECT_SKILLS=(
  better-useeffect
  database-migrations
  docker-patterns
  engineering-context
  frontend-patterns
  frontend-robust-data-handling
  js-ts-coding-standards
  pure-function-pattern
)

install_one_skill() {
  local action="$1" source_dir="$2" dest_root="$3" name="$4"
  local src="$SCRIPT_DIR/$source_dir/$name" dest="$dest_root/$name"
  if [[ "$action" == "install" ]]; then
    install_dir "$src" "$dest"
  elif [[ "$action" == "reinstall" ]]; then
    reinstall_dir "$src" "$dest"
  else
    uninstall_path "$dest"
  fi
}

setup_skills() {
  local action="$1" scope="$2" name="$3"

  if [[ "$scope" == "--global" ]]; then
    [[ "$action" == "uninstall" ]] || ensure_dir "$GLOBAL_SKILLS_DIR"
    if [[ -n "$name" ]]; then
      require_known_item "global skill" "$name" "${GLOBAL_SKILLS[@]}"
      install_one_skill "$action" "global-skills" "$GLOBAL_SKILLS_DIR" "$name"
    else
      for s in "${GLOBAL_SKILLS[@]}"; do
        install_one_skill "$action" "global-skills" "$GLOBAL_SKILLS_DIR" "$s"
      done
    fi
  elif [[ "$scope" == "--project" ]]; then
    [[ "$action" == "uninstall" ]] || ensure_dir "$PROJECT_SKILLS_DIR"
    if [[ -n "$name" ]]; then
      require_known_item "project skill" "$name" "${PROJECT_SKILLS[@]}"
      install_one_skill "$action" "project-skills" "$PROJECT_SKILLS_DIR" "$name"
    else
      for s in "${PROJECT_SKILLS[@]}"; do
        install_one_skill "$action" "project-skills" "$PROJECT_SKILLS_DIR" "$s"
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
  design-pattern-fit
  ddd-fit-check
  debug-triage
  learn
  mock-or-not
  setup-agentic-coding-project
  update-codemaps
)

setup_one_command() {
  local action="$1" dest_root="$2" name="$3"
  local src="$SCRIPT_DIR/commands/$name.md" dest="$dest_root/$name.md"
  if [[ "$action" == "install" ]]; then
    install_file "$src" "$dest"
  elif [[ "$action" == "reinstall" ]]; then
    reinstall_file "$src" "$dest"
  else
    uninstall_path "$dest"
  fi
}

setup_commands() {
  local action="$1" scope="$2" name="$3"

  if [[ "$scope" == "--global" ]]; then
    [[ "$action" == "uninstall" ]] || ensure_dir "$GLOBAL_COMMANDS_DIR"
    if [[ -n "$name" ]]; then
      require_known_item "command" "$name" "${COMMANDS[@]}"
      setup_one_command "$action" "$GLOBAL_COMMANDS_DIR" "$name"
    else
      for c in "${COMMANDS[@]}"; do
        setup_one_command "$action" "$GLOBAL_COMMANDS_DIR" "$c"
      done
    fi
  elif [[ "$scope" == "--project" ]]; then
    [[ "$action" == "uninstall" ]] || ensure_dir "$PROJECT_COMMANDS_DIR"
    if [[ -n "$name" ]]; then
      require_known_item "command" "$name" "${COMMANDS[@]}"
      setup_one_command "$action" "$PROJECT_COMMANDS_DIR" "$name"
    else
      for c in "${COMMANDS[@]}"; do
        setup_one_command "$action" "$PROJECT_COMMANDS_DIR" "$c"
      done
    fi
  else
    die "commands requires --global or --project"
  fi
}

# ── interactive menu ─────────────────────────────────────────────────────────

menu() {
  echo "agentic-coding setup ($PROVIDER)"
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
  echo "Run with arguments, e.g.:"
  echo "  ./setup.sh $PROVIDER install skills --global"
  echo "  ./setup.sh $PROVIDER reinstall skills --project frontend-patterns"
  echo "  ./setup.sh $PROVIDER uninstall commands --global mock-or-not"
  echo "  ./setup.sh $PROVIDER reinstall all --global"
}

# ── main ─────────────────────────────────────────────────────────────────────

case "${ACTION}" in
  menu)        menu ;;
  install | reinstall | uninstall)
    kind="${1:-}"
    scope="${2:-}"
    name="${3:-}"
    case "$kind" in
      skills)    setup_skills "$ACTION" "$scope" "$name" ;;
      commands)  setup_commands "$ACTION" "$scope" "$name" ;;
      all)
        setup_skills "$ACTION" "$scope" ""
        setup_commands "$ACTION" "$scope" ""
        ;;
      *) die "$ACTION requires skills, commands, or all" ;;
    esac
    ;;
  *)           menu ;;
esac
