#!/usr/bin/env bash
#
# setup.sh - Install, reinstall, or uninstall skills and commands from this repo.
#
# Usage:
#   ./setup.sh opencode                             # menu
#   ./setup.sh codex                                # menu
#   ./setup.sh opencode install skills --global     # install all global skills
#   ./setup.sh codex reinstall all --global         # reinstall all global skills + commands
#   ./setup.sh opencode install all --project --target /path/to/project
#   ./setup.sh codex reinstall skills --project frontend-patterns --dry-run
#   ./setup.sh opencode uninstall commands --project mock-or-not --target /path/to/project
#   ./setup.sh all install all --global             # install everything for every provider
#
# OpenCode global installs -> ~/.config/opencode/
# OpenCode project installs -> .opencode/ (current working directory)
# Codex global installs -> ~/.codex/
# Codex project installs -> .codex/ (current working directory)
# Claude global installs -> ~/.claude/
# Claude project installs -> .claude/ (current working directory)
# Gemini global skills -> ~/.gemini/skills/
# Gemini global commands -> ~/.gemini/commands/
# Gemini project skills -> .gemini/skills/ (current working directory)
# Gemini project commands -> .gemini/commands/ (current working directory)
# Note: a skill with a `compatibility:` field in its SKILL.md is installed only for the
#       listed providers; skills without the field install for every provider.

set -euo pipefail

ALL_PROVIDERS=(opencode codex claude gemini)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROVIDER="${1:-}"
DRY_RUN=false
PROJECT_TARGET=""
PROJECT_ROOT=""

if [[ "$PROVIDER" != "opencode" && "$PROVIDER" != "codex" && "$PROVIDER" != "claude" && "$PROVIDER" != "gemini" && "$PROVIDER" != "all" ]]; then
  echo "error: provider is required: opencode, codex, claude, gemini, or all" >&2
  echo "" >&2
  echo "Usage: ./setup.sh <opencode|codex|claude|gemini|all> [install|reinstall|uninstall] [skills|commands|all] [--global|--project] [name] [--target path] [--dry-run]" >&2
  exit 1
fi

shift

if [[ "$PROVIDER" == "all" ]]; then
  for p in "${ALL_PROVIDERS[@]}"; do
    echo "=== $p ==="
    "$0" "$p" "$@"
    echo ""
  done
  exit 0
fi
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
  PROJECT_SKILLS_REL=".opencode/skills"
  PROJECT_COMMANDS_REL=".opencode/commands"
elif [[ "$PROVIDER" == "claude" ]]; then
  GLOBAL_SKILLS_DIR="$HOME/.claude/skills"
  GLOBAL_COMMANDS_DIR="$HOME/.claude/commands"
  PROJECT_SKILLS_REL=".claude/skills"
  PROJECT_COMMANDS_REL=".claude/commands"
elif [[ "$PROVIDER" == "gemini" ]]; then
  GLOBAL_SKILLS_DIR="$HOME/.gemini/skills"
  GLOBAL_COMMANDS_DIR="$HOME/.gemini/commands"
  PROJECT_SKILLS_REL=".gemini/skills"
  PROJECT_COMMANDS_REL=".gemini/commands"
else
  GLOBAL_SKILLS_DIR="$HOME/.codex/skills"
  GLOBAL_COMMANDS_DIR="$HOME/.codex/prompts"
  PROJECT_SKILLS_REL=".codex/skills"
  PROJECT_COMMANDS_REL=".codex/prompts"
fi
PROJECT_SKILLS_DIR="$PROJECT_SKILLS_REL"
PROJECT_COMMANDS_DIR="$PROJECT_COMMANDS_REL"

# ── helpers ──────────────────────────────────────────────────────────────────

die() { echo "error: $*" >&2; exit 1; }

ensure_dir() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "  dry-run mkdir -p $1"
  else
    mkdir -p "$1"
  fi
}

configure_project_target() {
  local target="${PROJECT_TARGET:-$(pwd)}"
  [[ -d "$target" ]] || die "--target must be an existing directory: $target"
  PROJECT_ROOT="$(cd "$target" && pwd)"
  PROJECT_SKILLS_DIR="$PROJECT_ROOT/$PROJECT_SKILLS_REL"
  PROJECT_COMMANDS_DIR="$PROJECT_ROOT/$PROJECT_COMMANDS_REL"
}

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
  if [[ "$DRY_RUN" == true ]]; then
    echo "  dry-run install $src → $dest"
  else
    echo "  install $src → $dest"
    cp -R "$src" "$dest"
  fi
}

reinstall_dir() {
  local src="$1" dest="$2"
  if [[ "$DRY_RUN" == true ]]; then
    echo "  dry-run reinstall $src → $dest"
  else
    echo "  reinstall $src → $dest"
    rm -rf "$dest"
    cp -R "$src" "$dest"
  fi
}

uninstall_path() {
  local dest="$1"
  if [[ -e "$dest" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "  dry-run uninstall $dest"
    else
      echo "  uninstall $dest"
      rm -rf "$dest"
    fi
  else
    echo "  skip missing $dest"
  fi
}

install_file() {
  local src="$1" dest="$2"
  [[ ! -e "$dest" ]] || die "already exists: $dest (use reinstall)"
  if [[ "$DRY_RUN" == true ]]; then
    echo "  dry-run install $src → $dest"
  else
    echo "  install $src → $dest"
    cp -f "$src" "$dest"
  fi
}

install_gemini_command() {
  local action="$1" src="$2" dest="$3"
  local description
  description="$(sed -n '2s/^description:[[:space:]]*//p' "$src")"
  description="${description#\"}"
  description="${description%\"}"
  description="${description//\\/\\\\}"
  description="${description//\"/\\\"}"

  if [[ "$DRY_RUN" == true ]]; then
    echo "  dry-run $action $src → $dest"
  else
    echo "  $action $src → $dest"
    {
      printf "description = \"%s\"\n\nprompt = '''\n" "$description"
      awk '
        NR == 1 && $0 == "---" { frontmatter = 1; next }
        frontmatter && $0 == "---" { frontmatter = 0; body = 1; next }
        body { print }
      ' "$src"
      printf "\n'''\n"
    } > "$dest"
  fi
}

reinstall_file() {
  local src="$1" dest="$2"
  if [[ "$DRY_RUN" == true ]]; then
    echo "  dry-run reinstall $src → $dest"
  else
    echo "  reinstall $src → $dest"
    rm -f "$dest"
    cp -f "$src" "$dest"
  fi
}

# ── skills ───────────────────────────────────────────────────────────────────

GLOBAL_SKILLS=(
  api-design
  better-test-driven-development
  content-engine
  debugging-playbook
  domain-driven-design-advisor
  edit-article
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
  write-a-prd
  zoom-out
  super-google-search
)

PROJECT_SKILLS=(
  better-useeffect
  database-migrations
  docker-patterns
  frontend-patterns
  frontend-robust-data-handling
  js-ts-coding-standards
  pure-function-pattern
)

# Reads the `compatibility:` frontmatter field of a skill's SKILL.md.
# No field  -> compatible with every provider (the default).
# Field set -> compatible only with the listed providers. Accepts a bare value
#              (compatibility: opencode) or a list (compatibility: [opencode, claude]).
skill_compatible() {
  local source_dir="$1" name="$2"
  local skill_md="$SCRIPT_DIR/$source_dir/$name/SKILL.md"
  [[ -f "$skill_md" ]] || return 0
  local line
  line="$(grep -m1 '^compatibility:' "$skill_md" || true)"
  [[ -n "$line" ]] || return 0
  local raw="${line#compatibility:}"
  raw="${raw//[/ }"; raw="${raw//]/ }"; raw="${raw//,/ }"; raw="${raw//\"/ }"
  local p
  for p in $raw; do
    [[ "$p" == "$PROVIDER" ]] && return 0
  done
  return 1
}

install_one_skill() {
  local action="$1" source_dir="$2" dest_root="$3" name="$4"
  local src="$SCRIPT_DIR/$source_dir/$name" dest="$dest_root/$name"
  if [[ "$action" != "uninstall" ]] && ! skill_compatible "$source_dir" "$name"; then
    echo "  skip $name (not compatible with $PROVIDER)"
    return 0
  fi
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
  code-review
  design-pattern-fit
  ddd-fit-check
  debug-triage
  mock-or-not
  update-codemaps
  content-to-skill
)

setup_one_command() {
  local action="$1" dest_root="$2" name="$3"
  local src="$SCRIPT_DIR/commands/$name.md" dest="$dest_root/$name.md"
  if [[ "$PROVIDER" == "gemini" ]]; then
    dest="$dest_root/$name.toml"
    if [[ "$action" == "install" ]]; then
      [[ ! -e "$dest" ]] || die "already exists: $dest (use reinstall)"
      install_gemini_command install "$src" "$dest"
    elif [[ "$action" == "reinstall" ]]; then
      if [[ "$DRY_RUN" != true ]]; then
        rm -f "$dest"
      fi
      install_gemini_command reinstall "$src" "$dest"
    else
      uninstall_path "$dest"
    fi
    return 0
  fi
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
  echo "  ./setup.sh $PROVIDER install all --project --target /path/to/project"
  echo "  ./setup.sh $PROVIDER reinstall all --project --target /path/to/project --dry-run"
  echo "  ./setup.sh $PROVIDER uninstall commands --global mock-or-not"
  echo "  ./setup.sh $PROVIDER reinstall all --global"
  echo "  ./setup.sh all install all --global   # install for every agent at once"
  echo ""
  echo "Project target defaults to the current working directory."
}

# ── main ─────────────────────────────────────────────────────────────────────

case "${ACTION}" in
  menu)        menu ;;
  install | reinstall | uninstall)
    kind="${1:-}"
    [[ -n "$kind" ]] || die "$ACTION requires skills, commands, or all"
    shift

    scope=""
    name=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --global | --project)
          [[ -z "$scope" ]] || die "scope already set: $scope"
          scope="$1"
          shift
          ;;
        --target)
          shift
          [[ $# -gt 0 ]] || die "--target requires a path"
          PROJECT_TARGET="$1"
          shift
          ;;
        --dry-run)
          DRY_RUN=true
          shift
          ;;
        --*)
          die "unknown option: $1"
          ;;
        *)
          [[ -z "$name" ]] || die "unexpected argument: $1"
          name="$1"
          shift
          ;;
      esac
    done

    [[ -n "$scope" ]] || die "$kind requires --global or --project"
    [[ -z "$PROJECT_TARGET" || "$scope" == "--project" ]] || die "--target can only be used with --project"
    [[ "$kind" != "all" || -z "$name" ]] || die "all does not accept an item name"

    if [[ "$scope" == "--project" ]]; then
      configure_project_target
      echo "Project target: $PROJECT_ROOT"
    else
      echo "Global target: ${GLOBAL_SKILLS_DIR%/skills}"
    fi
    [[ "$DRY_RUN" == true ]] && echo "Dry run: no files will be changed"

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
