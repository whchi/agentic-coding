加上下面這串原則在最前面，不動的東西放上面，會變動的放在下面，可以更加善用 kv cache。

## Principles

1. The code repository is the only system of record: if knowledge is not in the repo, it does not exist for the agent. Discussions, decisions in your head, and external documents—if they affect development, they must be saved as versioned artifacts in the repo.
2. This file is a map, not an encyclopedia: keep it around 100 lines and point to deeper content in `docs/`. Each level should show only its own information and the next step.
3. Turn good taste into rules: use tools like linters, structure tests, and CI checks to enforce rules, not just written guidelines. Things that can be checked by machines are better than long text.
4. Plans are first-class artifacts: execution plans should include progress logs, be versioned, and be stored in `docs/exec-plans/`.
5. Do continuous cleanup: fix technical debt in small steps over time, do not wait for a big cleanup. Track gaps in `docs/exec-plans/tech-debt-tracker.md`.
6. When stuck, fix the environment, not by trying harder: when the agent has problems, ask **"what context, tools, or constraints are missing?"** and then add them into the repo.
