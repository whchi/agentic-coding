# agentic-coding

My agentic coding assets — engineering-focused skills, commands, and references.

This repo is built primarily for software engineering work. In this context, `global-skills/` means "reusable across engineering projects", not "useful for every possible Codex conversation." Non-engineering skills are included only when they support common builder workflows such as writing, planning, product thinking, or content.

## Quick Setup

```bash
# Clone this repo
git clone --depth 1 git@github.com:whchi/agentic-coding.git ~/agentic-coding
cd ~/agentic-coding

# Install all global skills + commands
./setup.sh opencode install all --global
./setup.sh codex install all --global
./setup.sh claude install all --global
./setup.sh gemini install all --global
./setup.sh pi install all --global
# or every provider at once
./setup.sh all reinstall all --global

# codex, gemini (project), and pi share `.agents/skills` (global: codex and pi share
# `~/.agents/skills`). After one of them is installed, `install` for the next stops with
# "already exists"; use `reinstall` for the rest, or for `all` as above.

# Install project skills + commands into another project
./setup.sh opencode install all --project --target /path/to/your/project
./setup.sh codex install all --project --target /path/to/your/project
./setup.sh claude install all --project --target /path/to/your/project
./setup.sh gemini install all --project --target /path/to/your/project
./setup.sh pi install all --project --target /path/to/your/project

# Or run from inside the target project
# cd /path/to/your/project
# ~/agentic-coding/setup.sh codex install all --project

# Or pick individual items
./setup.sh opencode install skills --global api-design
./setup.sh codex reinstall skills --project frontend-patterns --target /path/to/your/project
./setup.sh opencode uninstall commands --global mock-or-not

# Preview changes without writing files
./setup.sh codex reinstall all --project --target /path/to/your/project --dry-run
```

## Structure

| Directory | Target | Description |
|---|---|---|
| `global-skills/` | Provider global skills directory (see below) | Cross-project engineering skills |
| `project-skills/` | Provider project skills directory (see below) | Stack-specific or project-local engineering skills |
| `commands/` | Provider commands / prompts directory (see below) | Reusable command templates |
| `coding-agent-flow/` | Not installed | Skills for a future coding-agent workflow, kept together as one package; `setup.sh` does not install these yet. |
| `evals/` | Repository contributors | Versioned skill-routing and skill-behavior cases, and ignored run results; see [evals/README.md](evals/README.md). |
| `CONTEXT.example.md` | Copy to a project's repo root | Example domain glossary; copy to `CONTEXT.md` when needed. |

Install targets, as defined in `setup.sh`:

| Provider | Global skills | Global commands | Project skills | Project commands |
|---|---|---|---|---|
| opencode | `~/.config/opencode/skills/` | `~/.config/opencode/commands/` | `.opencode/skills/` | `.opencode/commands/` |
| codex | `~/.agents/skills/` | `~/.codex/prompts/` | `.agents/skills/` | `.codex/prompts/` |
| claude | `~/.claude/skills/` | `~/.claude/commands/` | `.claude/skills/` | `.claude/commands/` |
| gemini | `~/.gemini/config/skills/` | `~/.gemini/commands/` (TOML) | `.agents/skills/` | `.gemini/commands/` (TOML) |
| pi | `~/.agents/skills/` | `~/.pi/agent/prompts/` | `.agents/skills/` | `.pi/prompts/` |

The repository-evidence workflow in `grilling` creates context and decision documents only when a project needs them. See `CONTEXT.example.md` for a reference implementation of the format.

### Provider compatibility

Skills are organized by scope (global vs project), which is orthogonal to which CLI they run on. Provider-specificity is declared in each skill's `SKILL.md` frontmatter:

```yaml
compatibility: opencode        # or a list: [opencode, claude]
```

A skill **with** this field installs only for the listed providers; a skill **without** it installs for every provider (the default). `setup.sh` reads the field and skips incompatible skills, so e.g. `./setup.sh claude install all --global` will not install skills declared `compatibility: opencode`.

Gemini CLI custom commands live in `.gemini/commands/`. Because this repository stores provider-neutral commands as Markdown, `setup.sh gemini ...` converts each command to Gemini's required TOML format during installation. For skills, this setup installs Gemini globally to `~/.gemini/config/skills/` and per project to the interoperable `.agents/skills/` path (shared with Codex).

[Pi](https://pi.dev/docs/latest/skills) discovers skills in `~/.agents/skills/` and `.agents/skills/` (shared with Codex). Its [prompt templates](https://pi.dev/docs/latest/prompt-templates) are Markdown files in `~/.pi/agent/prompts/` and `.pi/prompts/`, so `setup.sh pi ...` installs repository commands unchanged.

### Global Skills

| Skill | Description |
|---|---|
| `api-design` | REST API design and review guidance |
| `benchmark-checklist` | Vet a measured number (limiter, tuning, errors, repeat runs, relevance) before you report it |
| `blast-radius` | Find what a change breaks outside its diff and prove the one fact that makes it safe |
| `concurrency-review` | Shared-state race, locking, idempotency, and cache-invalidation review |
| `correct` | Explicit `/correct` only: turn repeated agent mistakes into architecture, type, lint, or test enforcement |
| `debugging-playbook` | Methodical environment/data/logic debugging workflow |
| `domain-driven-design-advisor` | DDD fit, bounded context, aggregate, and layering guidance |
| `edit-article` | Article restructuring and editing workflow |
| `grilling` | Stress-test plans through questioning, with optional repository evidence, terminology, and ADR guidance |
| `handoff` | Compact current work into a durable handoff for another session or agent |
| `maintainable-code-review` | Maintainability, module depth, abstraction, and readability review guidance |
| `module-boundaries` | Folder/module organization and persistence, application, and domain responsibility placement |
| `product-engineering-mvp` | MVP build-vs-buy, cost, and product engineering tradeoffs |
| `reflect` | Explicit `reflect` only: mine the session transcript for skill edits, applied after approval |
| `testing-strategy` | Test design/review, plus conditional test-first implementation |
| `verification-harness` | Create or refresh a project-local `verify-<app>` skill that drives the real app |
| `why` | Find why code has its shape from the historical record, with confidence tiers |
| `write-a-prd` | PRD / spec writing workflow |
| `zoom-out` | Higher-level module map before editing unfamiliar code |

### Project Skills

| Skill | Description |
|---|---|
| `animate` | Build a single web animation with the right purpose, curve, duration, interruption, and reduced-motion handling |
| `feature-loop` | Staged feature workflow: open → plan → build → verify, with a feature document and a 2-round verify budget |
| `frontend-patterns` | React / Next.js components, state/effect boundaries, performance, and accessibility |
| `frontend-robust-data-handling` | Frontend adapters, defaults, null-object, and partial-data handling |
| `js-ts-coding-standards` | JS / TS / React / Node coding standards |
| `pure-function-pattern` | Pure business logic extraction and side-effect isolation |


### Commands

| Command | Description |
|---|---|
| `anthropic-skill-review` | Existing skill/command draft review |
| `code-review` | Code review workflow |
| `content-to-skill` | Distill explicit source material into a reusable skill draft |
| `design-pattern-fit` | Design pattern fit and overengineering check |
| `ddd-fit-check` | DDD adoption fit check |
| `debug-triage` | Environment/data/logic debugging triage |
| `mock-or-not` | Test dependency mock/fake/real decision checklist |
| `qa` | Scoped acceptance tests and browser Back / Forward / Reload state verification |
| `update-codemaps` | Code map update workflow |

Install the QA command with `./setup.sh <provider> install commands --global qa` (replace `<provider>` with a provider from the table above). Its source is [commands/qa.md](commands/qa.md); installation follows the same provider-specific paths and format conversion as other commands.

`qa` and `code-review` remain commands: explicit entry points for scoped acceptance verification and change review. `testing-strategy` remains a skill: reusable guidance on test levels, dependency boundaries, and fixtures for both workflows. QA produces acceptance evidence; code review assesses the change and its evidence. Reuse verifiable results for the same code state, environment, and scope instead of rerunning checks solely because the entry point changed.

### Coding Agent Flow (not installed)

Skills that will make up a future coding-agent workflow. Kept in `coding-agent-flow/` as one package and not installed by `setup.sh`; copy manually when needed.

| Skill | Description |
|---|---|
| `requirement-breakdown` | Turn requirements into user goals, Gherkin scenarios, and a tracker-agnostic `cards.json` backlog |
| `requirement-to-jira` | Create, update, or reconcile Jira cards from a `cards.json` via Jira MCP (depends on `requirement-breakdown`) |

### General Skills (not installed)

| Skill | Description |
|---|---|
| `serenity-seek-alpha` | Turn news, adoption, and industry events into a testable investment research path (no buy/sell calls or price targets) |
| `super-google-search` | Source-backed web search and research collection |

## Skill Taxonomy

| Area | Skills / Commands |
|---|---|
| Alignment | `grilling`, `write-a-prd`, `product-engineering-mvp` |
| Context | `zoom-out`, `update-codemaps`, `why`, `blast-radius` |
| Delivery | `feature-loop`, `testing-strategy`, `debugging-playbook`, `debug-triage`, `concurrency-review` |
| Testing | `testing-strategy`, `mock-or-not`, `qa`, `verification-harness`, `benchmark-checklist` |
| Architecture | `maintainable-code-review`, `module-boundaries`, `domain-driven-design-advisor`, `api-design`, `design-pattern-fit`, `ddd-fit-check` |
| Frontend | `frontend-patterns`, `frontend-robust-data-handling`, `js-ts-coding-standards`, `pure-function-pattern`, `animate` |
| Review | `code-review` |
| Skill authoring | `anthropic-skill-review`, `content-to-skill`, `reflect` |
| Feedback loop | `correct` |
| Writing | `edit-article` |
| Handoff | `handoff` |

### Skill boundaries

One entrypoint can route related tasks to conditional references: `grilling` covers both general interviews and repository-grounded questioning; `frontend-patterns` includes effect refactoring; `module-boundaries` separates folder organization from responsibility placement. Each installed skill contains its own required references.

Keep distinct outcomes independently discoverable:

- `frontend-robust-data-handling` handles payload normalization across UI frameworks; it is not limited to React.
- `domain-driven-design-advisor` owns DDD fit and aggregate modeling; `module-boundaries` handles concrete organization and ownership without requiring DDD.
- `testing-strategy` separates test design/review from test-first implementation. Asking which tests to write does not start TDD or authorize product edits; requested TDD and regression-guided known fixes use its test-first reference.
- `js-ts-coding-standards` covers language conventions; `pure-function-pattern` isolates deterministic domain decisions from side effects.
- `zoom-out`, `why`, and `blast-radius` answer current structure, historical rationale, and change impact respectively.
- `reflect` proposes skill improvements; `correct` implements enforcement for repeated mistakes. Both retain their explicit invocation boundaries.

Essential constraints may appear in independently installable skills. Do not remove them by creating a dependency on another skill's files or automatically loading a neighboring skill.

Verify the catalog and installed contents with `bash tests/command-skill-policy.sh` and `python3 tests/skill-consolidation-smoke.py`. The latter installs into temporary homes/projects for all supported providers; it does not alter existing user installations.

## Initialize a project's AGENTS.md

Run from this checkout, with the target Git repository root explicitly selected:

```bash
./init-project-agents.sh --target /path/to/project
# Preview the task and standard without a model call or file changes:
./init-project-agents.sh --target /path/to/project --dry-run
```

Requires an installed, authenticated Codex CLI. The script passes the local
[project AGENTS standard](docs/agents/project-agents-standard.md) to Codex, which
inspects the target with a read-only shell sandbox and returns a proposed document.
The script creates or updates only the target root `AGENTS.md`; it does not merely
print a prompt. Existing content is included in the review, with a backup retained
at the printed temporary path. Identical output skips the write. Model failures,
invalid output, symlink destinations, and detected changes during generation stop
the write. Avoid concurrent edits while running it. Review the generated guidance
before relying on it; command existence is inspected, not proof that tests passed.

This repository's own root is rejected because its `AGENTS.md` holds global rules.
The script neither commits nor pushes, and does not depend on `pstack/`. It uses
the configured Codex model and account, so a normal run makes a model request.
Other providers are not currently supported by this entry point.

Check the wrapper without a model call using
`python3 tests/init-project-agents-smoke.py`.

## References
### AGENTS.md
- [專案 AGENTS.md 初始化與審查標準](docs/agents/project-agents-standard.md)：初始化或修改其他 repo 的專案規則時使用；與本 repo 根目錄的全域行為規則分開。
- https://github.com/forrestchang/andrej-karpathy-skills
### skills
- https://github.com/ayghri/i-have-adhd
- https://github.com/mksglu/context-mode
- https://github.com/JuliusBrussee/caveman
- https://github.com/anthropics/skills
- https://github.com/coreyhaines31/marketingskills 行銷技能
```bash
git submodule add https://github.com/coreyhaines31/marketingskills.git .agents/marketingskills
```
- https://github.com/addyosmani/agent-skills.git
- https://github.com/othmanadi/planning-with-files
- https://github.com/muyen/meihua-yishu 梅花易數
- https://github.com/jinchenma94/bazi-skill 算命
- https://github.com/affaan-m/everything-claude-code
- https://github.com/code-yeongyu/oh-my-openagent
- https://github.com/obra/superpowers 放在 project-level 執行
```bash
cd path/to/project
# opencode.json[c]
{
    "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
}
```
- https://github.com/garrytan/gstack 產品決策 -> 架構把關
`/office-hours` -> `/plan-ceo-review` -> `/plan-eng-review`
```bash
cd /path/to/project

git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git .agents/skills/gstack
cd .agents/skills/gstack && ./setup --host auto --local
```
- https://github.com/EveryInc/compound-engineering-plugin 深度規劃、執行修正、專家審查、重複疊代

`/ce:plan` -> `/ce:work` -> `/ce:review` -> `/ce:compound`
```bash
cd /path/to/project

bunx @every-env/compound-plugin install compound-engineering --to opencode
```
- https://github.com/whchi/prompt2eng
- https://github.com/yetone/native-feel-skill
- https://github.com/tw93/waza engineer 思維
- https://github.com/mattpocock/skills real engineer skills
- https://github.com/backnotprop/pstack poteto 的工程流程（`cursor/plugins/pstack` mirror）；`why`、`blast-radius`、`benchmark-checklist`、`verification-harness`、`correct`、`reflect` 改寫自此，其餘規則融入既有 skills（決策紀錄：`docs/audits/pstack-fit-2026-10-08.md`）

#### UI/UX
- https://github.com/pbakaus/impeccable
- https://github.com/Leonxlnx/taste-skill
- https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- https://github.com/emilkowalski/skills `animate` 已 vendor 進 project-skills（`break-ui` 曾 vendor，後移除）；其餘（emil-design-eng, apple-design, mobile-native, animate-expo, write-swift, ask-sonner, animation-vocabulary, find-animation-opportunities）按需安裝：`npx skills@latest add emilkowalski/skills`；prototype, improve-animations, pick-ui-library 刻意不使用（決策紀錄：`docs/audits/emilkowalski-skills-fit-2026-10-06.md`）

### Commands
- https://x.com/alvinsng/status/2033969062834045089
- https://x.com/trq212/status/2033949937936085378

### MCPs
- https://github.com/jkudish/jev-mcp
- https://github.com/upstash/context7
- https://github.com/github/github-mcp-server
- https://docs.devin.ai/work-with-devin/deepwiki-mcp
- https://github.com/ChromeDevTools/chrome-devtools-mcp
- https://github.com/colbymchenry/codegraph
```bash
cd path/to/project

codegraph init -i
# opencode.json[c]
{
 "mcp": {
    "codegraph": {
      "type": "local",
      "command": ["codegraph", "serve", "--mcp"],
      "enabled": true
    }
  }
}
```
- https://exa.ai/mcp
### Others
- https://x.com/hylarucoder/status/2043202352447189368?s=20
- https://addyosmani.com/blog/agent-skills/
- https://x.com/Mnilax/status/2053116311132155938
- https://github.com/DietrichGebert/ponytail
```json
{
  "plugin": ["/path/to/pontyail/.opencode/plugins/ponytail.mjs"]
}
```
- https://github.com/alchaincyf/nuwa-skill
- https://youtu.be/tiN6T1LewmQ?si=QKDpz3RYGOYol90i
- https://x.com/sairahul1/status/2102694818485096803?s=61&t=gcYoBbs7MKWkPpEtJ0C0Dw
