# Epistemics

These rules control confidence when the evidence is historical, incomplete, or contradictory. A confident answer with weak evidence is the failure that this skill must prevent.

## Confidence tiers

Put each claim in one tier. The tier sets the output section and the wording.

### 1. Direct

A person wrote text that answers the question.

- Examples: a PR body, an issue, a code comment, a design document, or a chat message from the author.
- Example text: "This fixes pagination for users with more than 1000 items."
- Wording: present tense, no hedge. "This exists because X." Put the citation next to the claim.

### 2. Supported

Two or more indirect items agree. No single source states the claim.

- Example: the PR title says "improve performance", and the issue has a `perf` label. The nearby commits change the same performance-critical code.
- Wording: "The evidence points strongly to X." List each item and what it contributes.

### 3. Inferred

A reasonable reading of the context. No source supports the claim explicitly.

- Example: the PR merged on the same day as a production error, so it was probably a hotfix.
- Wording: use a hedge. Show the chain: "Given A and B, C is likely because D."

### 4. Speculative

A plausible hypothesis with thin evidence. Other explanations fit equally well.

- Example: "One possibility is a workaround for a browser bug, but we found no evidence from that time."
- Wording: "One possibility is X, but we have no direct evidence." Put these claims in Competing hypotheses.

### 5. Unknown

You searched and found no answer. This result is valid and important.

- Wording: name each source and each query. "We searched the issue tracker for A and B and read the 6 PRs that changed this file since 2023. None gave a reason."

## Wording

These words state a cause or an intent. Use them only for Direct or Supported claims, with a citation next to them: "because", "the reason is", "was designed to", "fixes", "the team decided".

These words show a hedge. Use them for Inferred and Speculative claims: "appears to", "likely", "suggests", "is consistent with", "one reading is", "may have been".

Do not use these words: "obviously", "clearly", "of course", "just", "I think", "I believe".

## Rationalization

Code that is logical today possibly had a different reason, or a wrong reason. Do not invent a clean reason for messy history.

- Do not start from the assumption that the author made the correct decision.
- Do not treat a repeated pattern as intentional. It can be a copy.
- Do not treat an absence of evidence as evidence of absence.

## A hypothesis in the question

The user can include a hypothesis in the question. Treat it as one candidate. Examine the evidence independently. Say whether the evidence supports the hypothesis, and cite the items.

## Contradictory evidence

When two sources disagree, show both claims with their citations. Do not select the source that gives a simpler story.

Example: the issue says "customer X needs this for compliance", and the PR says "clean up tech debt". Both can be true, because the issue gave the motivation and the PR gave the author's description. One source can also be wrong. Give both to the user and let the user decide.

## Missing evidence

An honest "we do not know" is a useful result. It tells the user to ask a person, such as the author or the product owner. It also tells the user that the obvious sources do not contain the answer.

For each gap, state:

- the question that you tried to answer;
- the sources that you searched;
- the queries that you used in each source;
- the result (nothing, or only related material).

## Calibration check

Do this check before you return the output.

1. Make sure that each claim in "What we found" has a citation. If not, move the claim to a lower tier.
2. Make sure that the wording matches the tier.
3. Make sure that no claim uses the code as evidence for its own intent.
4. Make sure that each contradiction is in the output.
5. Make sure that a hypothesis from the user was examined, not accepted.
6. Make sure that "What we do not know" names specific gaps. If it is empty, examine the evidence again.
