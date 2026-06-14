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

# Install project skills + commands into another project
./setup.sh opencode install all --project --target /path/to/your/project
./setup.sh codex install all --project --target /path/to/your/project

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
| `global-skills/` | `~/.config/opencode/skills/` or `~/.codex/skills/` | Cross-project engineering skills |
| `project-skills/` | `.opencode/skills/` or `.codex/skills/` | Stack-specific or project-local engineering skills |
| `commands/` | OpenCode `commands/` or Codex `prompts/` | Reusable command templates |
| `CONTEXT.example.md` | Repo root | Example domain glossary following the `grill-with-docs` CONTEXT-FORMAT. Copy to `CONTEXT.md` in your own repo. |

Project context docs such as `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `docs/plans/`, and `docs/agents/` are created lazily by `grill-with-docs` when a project needs them. See `CONTEXT.example.md` in this repo for a reference implementation of the format.

### Global Skills

| Skill | Description |
|---|---|
| `api-design` | REST API design and review guidance |
| `better-test-driven-development` | Strict TDD workflow with 80%+ coverage |
| `content-engine` | Multi-platform content creation and repurposing |
| `debugging-playbook` | Methodical environment/data/logic debugging workflow |
| `domain-driven-design-advisor` | DDD fit, bounded context, aggregate, and layering guidance |
| `edit-article` | Article restructuring and editing workflow |
| `frontend-slides` | HTML slide deck / PPTX conversion workflow |
| `grill-me` | Plan/design stress-testing via questioning |
| `grill-with-docs` | Stress-test plans against project docs, domain language, code evidence, and ADRs |
| `handoff` | Compact current work into a durable handoff for another session or agent |
| `iterative-retrieval` | Progressive context retrieval for large or unfamiliar codebases |
| `maintainable-code-review` | Maintainability, module depth, abstraction, and readability review guidance |
| `planning-with-files` | File-based planning artifacts for complex work |
| `product-engineering-mvp` | MVP build-vs-buy, cost, and product engineering tradeoffs |
| `project-structure-advisor` | Folder structure and module boundary guidance |
| `repository-boundary-review` | Repository, DAO, service, and aggregate boundary review |
| `testing-strategy` | Test level, mocking, fixture, and coverage strategy |
| `write-a-skill` | Create or refine concise, composable agent skills |
| `write-a-prd` | PRD / spec writing workflow |
| `zoom-out` | Higher-level module map before editing unfamiliar code |

### Project Skills

| Skill | Description |
|---|---|
| `better-useeffect` | React / Next.js `useEffect` refactoring patterns |
| `database-migrations` | Production-safe schema migration guidance |
| `docker-patterns` | Docker / Compose architecture and troubleshooting |
| `frontend-patterns` | React / Next.js component, state, performance, a11y |
| `frontend-robust-data-handling` | Frontend adapters, defaults, null-object, and partial-data handling |
| `js-ts-coding-standards` | JS / TS / React / Node coding standards |
| `pure-function-pattern` | Pure business logic extraction and side-effect isolation |

### Commands

| Command | Description |
|---|---|
| `anthropic-skill-review` | Anthropic-style skill review |
| `build-fix` | Build failure diagnosis and fix |
| `code-review` | Code review workflow |
| `design-pattern-fit` | Design pattern fit and overengineering check |
| `ddd-fit-check` | DDD adoption fit check |
| `debug-triage` | Environment/data/logic debugging triage |
| `learn` | Learning / exploration workflow |
| `mock-or-not` | Test dependency mock/fake/real decision checklist |
| `update-codemaps` | Code map update workflow |

## Skill Taxonomy

| Area | Skills / Commands |
|---|---|
| Alignment | `grill-me`, `grill-with-docs`, `write-a-prd` |
| Context | `iterative-retrieval`, `zoom-out`, `update-codemaps` |
| Delivery | `better-test-driven-development`, `debugging-playbook`, `planning-with-files` |
| Architecture | `maintainable-code-review`, `repository-boundary-review`, `project-structure-advisor`, `design-pattern-fit`, `ddd-fit-check` |
| Handoff | `handoff`, `write-a-skill` |

## References
### AGENTS.md
- https://github.com/forrestchang/andrej-karpathy-skills
### skills
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

#### UI/UX
- https://github.com/pbakaus/impeccable
- https://github.com/Leonxlnx/taste-skill
- https://github.com/nextlevelbuilder/ui-ux-pro-max-skill

### Commands
- https://x.com/alvinsng/status/2033969062834045089
- https://x.com/trq212/status/2033949937936085378

### MCPs
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
### Others
- https://x.com/hylarucoder/status/2043202352447189368?s=20
- https://addyosmani.com/blog/agent-skills/
- https://x.com/Mnilax/status/2053116311132155938
