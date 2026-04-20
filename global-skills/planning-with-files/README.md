# Planning with Files

Manus-style file-based planning skill for OpenCode. Use persistent markdown files as "working memory on disk" to handle complex multi-step tasks without losing context.

## How It Works

```
Context Window = RAM (volatile, limited)
Filesystem = Disk (persistent, unlimited)
```

Three files work together:

| File | Purpose |
|------|---------|
| `task_plan.md` | Roadmap — phases, progress, decisions, errors |
| `findings.md` | Knowledge base — research, discoveries, technical decisions |
| `progress.md` | Session log — chronological record of actions and test results |

## Installation

### Skill

Place the skill directory in one of OpenCode's search paths:

- Project: `.opencode/skills/planning-with-files/SKILL.md`
- Global: `~/.config/opencode/skills/planning-with-files/SKILL.md`

### Plugin (Optional — for automated hooks)

Place `scripts/planning-plugin.js` in `.opencode/plugins/` or add to `opencode.json`:

```json
{
  "plugin": ["path/to/planning-plugin.js"]
}
```

The plugin provides:
- `tool.execute.before` — Injects plan context before tool execution
- `tool.execute.after` — Reminds to update progress after writes
- `session.idle` — Runs completion check when session ends

### Session Recovery

Run before resuming work after a session break:

```bash
node scripts/session-catchup.js "$(pwd)"
```

## File Structure

```
planning-with-files/
├── SKILL.md                  # Agent-facing instructions (frontmatter + rules)
├── README.md                 # This file — human documentation
├── reference.md              # Manus context engineering principles
├── examples.md               # Real-world usage examples
├── templates/
│   ├── task_plan.md          # Phase tracking template
│   ├── findings.md           # Research storage template
│   └── progress.md           # Session logging template
└── scripts/
    ├── init-session.sh       # Initialize all planning files
    ├── check-complete.sh     # Verify all phases complete
    ├── session-catchup.js    # Session recovery (Node.js)
    └── planning-plugin.js    # OpenCode plugin (hooks replacement)
```

## Where Files Go

- **Templates** live in the skill directory
- **Planning files** (`task_plan.md`, `findings.md`, `progress.md`) go in your **project root**

## When to Use

Use for multi-step tasks, research, feature development, bug fixes spanning multiple files. Skip for simple questions, single-file edits, or quick lookups.

## Advanced Topics

- [Manus Principles](reference.md) — KV-cache, context engineering strategies
- [Real Examples](examples.md) — Research, bug fix, feature development patterns
