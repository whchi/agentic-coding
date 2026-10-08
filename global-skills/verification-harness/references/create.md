# Mode `create`: full procedure

Write the generated skill for the next agent, not for a person. That agent reads it without context, during a task, and has not seen the app before.

## 1. Get facts from the repo

Answer these questions from the codebase. Ask the user only for facts that you cannot observe.

- **Surface:** What does a user touch? Examples are a web UI, a CLI, a TUI, a desktop app, an API, a mobile app, and a library. A repo can have more than one surface. Select the primary surface and write the other surfaces in the skill.
- **Run:** How does the app start locally? Prefer the dev command that the repo documents, such as package scripts, a Makefile, or the README quickstart. Write the ports, environment variables, seed data, and authentication.
- **Drive:** How can an agent operate the app with a program? Use an existing harness first, such as Playwright specs, expect scripts, PTY helpers, HTTP endpoints, or a debug port. If no harness exists, use a generic method: browser automation for web and Electron, a tmux or PTY session for CLI and TUI, and HTTP for services.
- **Observe:** Which evidence can you capture? Examples are screenshots, terminal transcripts, response bodies, logs, exit codes, and database state.
- **Isolate:** Can two instances run at the same time with different ports, data folders, and profiles? If not, write this limit in the generated skill. The generated skill must refuse to drive a shared instance.

If the checkout fails to build or start, diagnose whether the failure belongs to the harness or the product. Correct harness mistakes within scope; report unrelated product fixes and obtain any additional authorization they require. Continue useful authoring, but label unproved launch steps as draft.

Create disposable verification scaffolding only within the authorized scope. Document why it is needed, keep it separate from product state, and clean it according to repository rules.

Do not install tools outside the authorized scope. If a required tool is missing, report the blocked proof and continue steps that do not depend on it.

## 2. Generated skill contract

Write `verify-<app>/SKILL.md` with YAML frontmatter. Set `name: verify-<app>`. Write a `description` that names the app, the surface, and when to use the skill. Without frontmatter, the skill does not register.

Write these sections. Base each section on facts from step 1. Do not leave placeholders.

- **Launch:** Give the exact command that starts the app for verification. Give the signal that the app is ready, such as a log line, a port that answers, or a prompt. Give the stop command. For a short-lived CLI or TUI, there is no server. Then Launch builds the binary or installs the dependencies one time. Each drive starts in its own isolated PTY or tmux session.
- **Doctor:** Give one read-only check that tells if the instance is correct to drive. Check the process, the version or build, the port owner, and the authentication. An agent runs Doctor first, and again when a result is unexpected.
- **Drive:** Give the harness method with real selectors and commands from this repo. Prefer stable handles, such as ARIA roles and names, data attributes, prompt strings, and route paths. Do not use screen coordinates or tab order.
- **Evidence:** Say what to capture and where to put it. Write the proof standards in the section that follows.
- **Cleanup:** Stop the instances that the run started, and remove scratch state. Do not stop a process by its name. Do not remove evidence. Name the location where evidence stays after Cleanup.
- **Helpers:** Make each helper script executable. Show its exact command in the skill body.

## 3. Proof standards for the Evidence section

- Use the real user path. Do not use internal setters or test-only endpoints.
- Capture the user action and the resulting state, not only the final screen.
- Check side effects when they define the requirement, such as a saved file or durable record. Do not send real messages or mutate shared services merely to gather proof without authorization.
- Use mocks only where a production boundary already isolates the external system.
- A dry-run or test mode can still touch the network or open a browser. Observe what it skips, such as files, network calls, and git refs. Do not trust its name.
- Keep evidence files out of source control. Write the evidence location in the skill.

## 4. User configuration

Put user configuration in a file apart from the generated assets. An example is `verify-<app>/config.example.env`, committed with secret-free values. The real values stay in an uncommitted file or in the environment.

- Generated assets: `SKILL.md` and the helper scripts. A refresh can rewrite them.
- User configuration: URLs, ports, accounts, fixture names, and secret variable names. A refresh does not overwrite them.
- Feature map: the durable verification record. A refresh edits it only with proof from a live drive.

Give each parallel worker its own account, profile, data folder, and port. Do not let two workers share a session or a token.

## 5. Feature map

Write `verify-<app>/features/README.md` and entries for the requested or highest-value features, discovered from routes, commands, menus, or documentation. State the mapped scope; creating an initial harness does not require mapping the whole app.

Use the shape in [feature-map-example/README.md](feature-map-example/README.md). Its Notes app, commands, and selectors are illustrative; discover the real equivalents instead of copying them as facts. Each feature file has an H1 title and one paragraph. Then it has exactly four H2 sections, in this order:

1. `Sub-features`
2. `How to get to it (user POV)`
3. `Driving it with <harness>`
4. `Gotchas`

Write each file from the point of view of the user. Say what the feature is, how to reach it, and how to drive it. Say which observable end state proves it. The map is the maintained verification record for the repo. Record the entry points actually driven; do not claim untested alternatives passed. Creating the harness requires one representative live proof, while acceptance coverage follows the selected task scope.

## 6. Prove the generated skill

1. Run Launch.
2. Run Doctor.
3. Drive one mapped feature. One feature is sufficient. Later runs can use the map for the other features.
4. Capture the evidence.
5. Run Cleanup.
6. Confirm that the evidence is still at its named location. A Cleanup that removes the evidence fails this step.
7. If a step fails, run the generated Cleanup before the next attempt. This prevents stray processes and ports.
8. Correct the skill and run the proof again.

## 7. Handoff

Tell the user the location of the `verify-<app>` skill and the feature that you proved. Tell the user that mode `refresh` keeps the map correct when the app changes. Suggest a schedule only if the user asks.
