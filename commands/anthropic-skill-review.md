---
description: "Review an existing SKILL.md or command draft for precise triggers, useful constraints, and maintainability."
---

# /anthropic-skill-review

Review the supplied draft or repository file. If several targets are plausible, state the smallest reversible scope assumption; ask only when selecting the wrong target would materially change the result.

A useful draft activates for a concrete task, adds guidance the model needs, and defines a recognizable finished result.

## Review criteria

- **Trigger:** describe the task that needs this method. Remove broad keywords, long synonym lists, and claims that every adjacent task needs the skill. Add exclusions only for a likely boundary confusion.
- **Context:** load documentation and examples only when their contents affect the current task. Give each supporting reference a purpose and loading condition.
- **Instructions:** retain domain decisions, failure modes, tool constraints, and evidence requirements. Remove generic advice, repeated rules, fixed step counts, and procedures that merely narrate ordinary reasoning.
- **Completion:** define the outcome and essential checks. Let authorized work continue through verification and repair; retain real safety and review-only boundaries.
- **Packaging:** verify referenced resources are available after installation. Standalone commands must not depend on companion files their installer omits.

Report only material problems, with their location, consequence, and smallest useful rewrite. Preserve working structure and the author's intent. A clean review is valid; do not manufacture changes or a long report.

Review invocation authorizes inspection and suggested rewrites. Apply edits when the user has also requested optimization or revision; do not ask again for that existing authorization. Validate changed frontmatter, references, and diff, adding execution checks only for changed executable behavior.

Finish with the verdict, material findings or completed edits, and verification limits.
