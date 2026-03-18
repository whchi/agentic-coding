---
description: "Review a draft skill using Anthropic's skill-writing heuristics: trigger quality, structure, gotchas, progressive disclosure, and long-term maintainability. Use when the user wants to refine a reusable skill rather than just summarize it."
---

# /anthropic-skill-review

Review the target skill using the principles from Anthropic's article on writing effective skills.

## When to use

Use this command when the user wants to:

- turn notes or an article into a reusable skill
- review a draft `SKILL.md`
- improve trigger wording, structure, or maintainability
- catch weak spots before sharing a skill with others

## Inputs

Expect one of these:

- a `SKILL.md` path
- pasted skill content
- a source article or notes plus a request to turn it into a reusable skill

If the target is ambiguous, identify the most likely file from context and state that assumption before reviewing.

## Review lens

Evaluate the target against these questions:

1. **Purpose clarity**
   - Is it obvious what the command is for?
   - Does it solve a repeatable problem instead of restating generic advice?

2. **Trigger quality**
   - Does the description tell the model when to use it, not just what it is?
   - Are the trigger phrases concrete enough to avoid under-triggering?

3. **Signal over noise**
   - Does it avoid stating the obvious?
   - Does every section earn its tokens?

4. **Progressive disclosure**
   - Is the main file focused?
   - If the content is heavy, should parts move into supporting references instead of bloating the core skill?

5. **Gotchas**
   - Does it call out common failure modes or misuse patterns?
   - Does it warn about over-constraining the model, vague descriptions, or missing context?

6. **Flexibility**
   - Does it guide the model without railroading it?
   - Are instructions specific where fragility matters, and loose where judgment is needed?

7. **Reuse and maintenance**
   - Will this still make sense after the original conversation is forgotten?
   - Is it suitable for sharing, iterating, and improving over time?

## Output format

Return a practical review in this structure:

### Verdict
- 1-2 sentences on whether the skill is usable as-is

### Strong parts
- Short bullets of what already works well

### Problems to fix
- Prioritized bullets
- Explain why each issue matters

### Suggested rewrite
- Provide improved frontmatter and any rewritten sections that would materially improve the result

### Recommendation
- End with one of:
   - `Keep as skill`
   - `Revise skill structure`
   - `Split skill core + references`

## Rewrite guidance

When rewriting:

- preserve the user's intent
- prefer concise wording
- make the description more triggerable
- remove generic filler
- add a gotchas section if the draft lacks one
- keep the skill practical and easy to invoke in future sessions

## Important defaults

- If the content is too broad, recommend splitting the skill into a focused core file plus supporting references.
- If the content is too procedural or repetitive, recommend moving repeatable helper steps into scripts or assets inside the skill folder.
- If the description is vague, rewrite it so it describes when the skill should trigger, not just what the skill is.

Do not just summarize the source article. Turn it into actionable review guidance.
