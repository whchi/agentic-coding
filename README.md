# agentic-coding

My agentic coding assets — skills, commands, and references.

## Quick Install

```bash
# Clone this repo
git clone --depth 1 git@github.com:whchi/agentic-coding.git ~/agentic-coding
cd ~/agentic-coding

# Install all global skills + commands
./install.sh all --global

# Install project skills + commands into current project
./install.sh all --project

# Or pick individual items
./install.sh skills --global api-design
./install.sh skills --project frontend-patterns
./install.sh commands --global tdd
```

## Structure

| Directory | Target | Description |
|---|---|---|
| `global-skills/` | `~/.config/opencode/skills/` | Cross-project reusable skills |
| `project-skills/` | `.opencode/skills/` | Stack-specific skills |
| `commands/` | `~/.config/opencode/commands/` or `.opencode/commands/` | Reusable command templates |

### Global Skills

| Skill | Description |
|---|---|
| `api-design` | REST API design and review guidance |
| `better-test-driven-development` | Strict TDD workflow with 80%+ coverage |
| `content-engine` | Multi-platform content creation and repurposing |
| `docker-patterns` | Docker / Compose architecture and troubleshooting |
| `edit-article` | Article restructuring and editing workflow |
| `grill-me` | Plan/design stress-testing via questioning |
| `iterative-retrieval` | Progressive context retrieval for large codebases |
| `write-a-prd` | PRD / spec writing workflow |

### Project Skills

| Skill | Description |
|---|---|
| `better-useeffect` | React / Next.js `useEffect` refactoring patterns |
| `database-migrations` | Production-safe schema migration guidance |
| `frontend-patterns` | React / Next.js component, state, performance, a11y |
| `frontend-slides` | HTML slide deck / PPTX conversion workflow |
| `js-ts-coding-standards` | JS / TS / React / Node coding standards |
| `pure-function-pattern` | Pure business logic extraction (TS-first) |
| `skill-creator` | Skill authoring, evaluation, and benchmarking |

### Commands

| Command | Description |
|---|---|
| `anthropic-skill-review` | Anthropic-style skill review |
| `build-fix` | Build failure diagnosis and fix |
| `code-review` | Code review workflow |
| `learn` | Learning / exploration workflow |
| `tdd` | TDD workflow |
| `update-codemaps` | Code map update workflow |

## References
### AGENTS.md
- https://github.com/forrestchang/andrej-karpathy-skills
### skills
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
- https://github.com/obra/superpowers
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
- https://github.com/mattpocock/skills

#### UI/UX
- https://github.com/pbakaus/impeccable
- https://github.com/Leonxlnx/taste-skill
- https://github.com/nextlevelbuilder/ui-ux-pro-max-skill

### Commands
- https://github.com/gsd-build/get-shit-done
- https://x.com/alvinsng/status/2033969062834045089
- https://x.com/trq212/status/2033949937936085378

### MCPs
- https://github.com/mksglu/context-mode
- https://github.com/upstash/context7
- https://github.com/github/github-mcp-server
- https://docs.devin.ai/work-with-devin/deepwiki-mcp
- https://github.com/ChromeDevTools/chrome-devtools-mcp

### Others
- https://x.com/hylarucoder/status/2043202352447189368?s=20
- https://addyosmani.com/blog/agent-skills/
