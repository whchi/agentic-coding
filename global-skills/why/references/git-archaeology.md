# Git Archaeology

Git archaeology is the default source. It is attached directly to the code, and it is always available through `git` and `gh`.

## What the source contains

- Commit messages, dates, authors, and diffs.
- PR bodies, review comments, and linked issues.
- Code comments: `TODO`, `FIXME`, `HACK`, and deprecation notes.
- ADRs, CHANGELOG entries, and release notes in the repository.
- Tests. Test names and assertions often record the edge case that caused a change.
- Files that changed in the same commit.

## Commands

```bash
# History of the file, through renames
git log --follow --oneline -- <file>

# History of a line range or a function
git log -L <start>,<end>:<file>
git log -L :<function>:<file>

# Commits that added or removed this exact text
git log -S '<exact string>' -- <file>

# Commits whose diff matches a regex
git log -G '<regex>' -- <file>

# Last commit for each line
git blame -L <start>,<end> <file>

# Ignore whitespace and moved lines
git blame -w -C -C -L <start>,<end> <file>

# One commit in full
git show <hash>

# PR number from a commit message, often "(#1234)"
git log -1 --format=%B <hash>

# PR context
gh pr view <number> --json title,body,author,createdAt,mergedAt,labels,closingIssuesReferences,comments,reviews,files

# Linked GitHub issue
gh issue view <number> --comments
```

Search near the target:

```bash
rg -n -C2 '(TODO|FIXME|HACK|XXX|NOTE)' <file>
rg -l '<symbol>' --glob '*test*'
rg -l -i 'decision|ADR' docs/
```

## Good evidence

- A PR body that states the problem, not only the change.
- A review thread that compares alternatives.
- A comment near the target that states a constraint.
- A test name that states an edge case, such as `handles_empty_cursor`.
- A commit message with an issue ID or an incident ID.
- A revert, followed by a commit that applies the change again with a modification.

## Common errors

- **Squash merges.** The branch commits are not available. Use the PR body and the review comments.
- **Wrong commit messages.** A message such as "small refactor" can hide a change in behavior. Read the diff.
- **Copied patterns.** The author possibly copied a pattern from other code. Find the commit that first added the pattern and examine that commit.
- **Bot commits.** Dependency bots and automatic backports do not contain motivation. Ignore them when you search for intent.
- **Code as evidence.** A function name is not evidence of intent. Evidence is text that a person wrote about the code.
- **No `gh` access.** If `gh` fails, record "PR and issue context not available" as a gap. Do not guess the PR content.
