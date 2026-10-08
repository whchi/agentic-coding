---
name: reflect
description: Use only when the user explicitly says "reflect" or "/reflect". Reviews the current session transcript with three review lenses and a synthesizer, then proposes skill edits for approval. Do NOT use on your own initiative, at the end of a normal task, or to fix a repeated code mistake (use `correct`).
origin: backnotprop/pstack@3a60467 (MIT)
---

# Reflect

Find durable learnings in the current session. Change each accepted learning into a specific skill edit.

Do not run the review when the session is trivial or off-topic. Do not run it when the agent obeyed an existing skill correctly. A one-time event is not a learning.

## 1. Find the transcript

Read only the sessions of the current workspace. Do not search the session directories of other projects. Those files contain private work from unrelated projects.

- **Claude Code:** `~/.claude/projects/<slug>/*.jsonl`. The `<slug>` is the workspace path with each character that is not a letter or digit changed to `-`.
- **Codex:** `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`. Keep only the files whose first line has `payload.cwd` equal to the workspace path.
- **Pi:** `~/.pi/agent/sessions/--<slug>--/*.jsonl`. The `<slug>` is the workspace path without the first `/`, with each `/` changed to `-`.
- **OpenCode:** `~/.local/share/opencode/storage/`. Use only the sessions of the project whose record has the workspace path.

Examine the newest files first. Confirm a file when its first user message is the first prompt of this session. If no file matches, write a short digest of the session. Use the digest in place of the path.

## 2. Run the three lenses

| Lens | Prompt template |
|---|---|
| Judgment | `references/judgment-reviewer.md` |
| Tooling | `references/tooling-reviewer.md` |
| Divergent | `references/divergent-reviewer.md` |

1. Copy each template without changes.
2. Put the transcript path or the digest in the marked location.
3. Give each prompt to one subagent. Start the three subagents in parallel.

If the harness lets you select a model for each subagent, you can use a different model for each lens. If the harness has no subagent tool, do each lens yourself, one after the other, with the same model.

## 3. Synthesize

1. Copy `references/synthesizer.md` without changes.
2. Put the full output of each lens in its marked location.
3. Give the prompt to one subagent, or do it yourself.

The synthesizer gives an Accepted, Rejected, and Backlog list. Its filter puts each finding in one of four classes:

| Class | Result |
|---|---|
| Missing trigger: the skill did not start when it was necessary | Accepted: tune the description |
| Unclear guidance: the skill text is weak, hidden, or incomplete | Accepted: edit the skill body |
| The agent did not obey guidance that is already clear | Backlog: no text edit; send to `correct` |
| A mechanism can enforce the rule better than text | Backlog: send to `correct` |

## 4. Get approval

1. Show the full Accepted, Rejected, and Backlog output to the user.
2. Wait for explicit approval.
3. Apply only the rows that the user approves. The user can also change a routing.

Skill changes affect each future agent. Do not apply a change without approval.

## 5. Apply

Select the write-back target:

- **The current repo is the skill source repo.** The repo has `global-skills/` and `setup.sh`. Edit the source files in `global-skills/` or `project-skills/`. Then tell the user to run `./setup.sh <provider> reinstall skills --global <skill-name>`. Use `--project` for a skill in `project-skills/`.
- **Any other project.** Write the approved rows to `docs/agents/reflect-<YYYY-MM-DD>.md` in that project. The user copies the proposals to the skill source repo.

Never edit installed copies, for example in `~/.claude/skills/`, `~/.agents/skills/`, `.claude/skills/`, or `.agents/skills/`. The next install replaces them.

For each approved row in the source repo, use the Routing field:

- **Small edit** (one bullet, one sentence, or one incorrect fact): make the edit yourself.
- **Large edit** (a new section, a new table, or more than 10 lines): use the skill-authoring skill. An example is `skill-creator`. If there is none, use the Agent Skills format at agentskills.io.
- **`tune description: <skill path>`**: edit the description so that it starts on the missed trigger.
- **`new skill: <kebab-name>`**: use the skill-authoring skill. Do not invent a new format.

If the repo has a SKILL.md validator, run it on each changed skill.

Give the Backlog to `correct` only if the user asks. Otherwise list the Backlog in the summary.

## 6. Summarize

Write a short list, with no introduction:

- Edits applied: `<skill path>`, one line for each change.
- Proposals written: `docs/agents/reflect-<YYYY-MM-DD>.md`, if not in the source repo.
- Reinstall command, if you edited source files.
- Backlog for `correct`: one line for each item.
- Rejected: one line for each finding, with the reason from the synthesizer.
