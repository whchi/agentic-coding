# Mode `create`: full procedure

Write the generated skill for the next agent, not for a person. That agent reads it without context, during a task, and has not seen the app before.

## 1. Get facts from the repo

Answer these questions from the codebase. Ask the user only for facts that you cannot observe.

- **Surface:** What does a user touch? Examples are a web UI, a CLI, a TUI, a desktop app, an API, a mobile app, and a library. A repo can have more than one surface. Select the primary surface and write the other surfaces in the skill.
- **Run:** How does the app start locally? Prefer the dev command that the repo documents, such as package scripts, a Makefile, or the README quickstart. Write the ports, environment variables, seed data, and authentication.
- **Drive:** How can an agent operate the app with a program? Use an existing harness first, such as Playwright specs, expect scripts, PTY helpers, HTTP endpoints, or a debug port. If no harness exists, use a generic method: browser automation for web and Electron, a tmux or PTY session for CLI and TUI, and HTTP for services.
- **Observe:** Which evidence can you capture? Examples are screenshots, terminal transcripts, response bodies, logs, exit codes, and database state.
- **Isolate:** Can two instances run at the same time with different ports, data folders, and profiles? If not, write this limit in the generated skill. The generated skill must refuse to drive a shared instance.

The checkout can fail to build or start. Then report the exact failure and stop. Fix it only after the user approves. A skill that you write against a broken base teaches incorrect steps.

A missing asset that is not related to the test can block startup. An example is a static folder that the API does not serve. With user approval, the generated skill can create that asset. Mark it as verification scaffolding, and remove it in Cleanup.

Do not install a tool without user approval. If a necessary tool is missing, report it and stop.

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
- Check side effects, such as files written, rows inserted, and messages sent.
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

Write `verify-<app>/features/README.md`. Write one file for each user-facing feature that you can find. Start with the top 3 to 5 features. Find them from routes, commands, menus, or documentation.

Use the shape in `feature-map-example/`. Each feature file has an H1 title and one paragraph. Then it has exactly four H2 sections, in this order:

1. `Sub-features`
2. `How to get to it (user POV)`
3. `Driving it with <harness>`
4. `Gotchas`

Write each file from the point of view of the user. Say what the feature is, how to reach it, and how to drive it. Say which observable end state proves it. The map is the maintained verification record for the repo. A proof that drives one entry point is incomplete when the map lists other entry points.

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
