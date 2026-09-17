# StyLua for Roblox Studio

StyLua for Roblox Studio is a plugin that formats Lua and Luau source inside Studio. It bundles StyLua compiled to WebAssembly and transpiled to Luau, with a React and Foundation settings UI.

It lets game creators format the active script or selected scripts without running an external formatter process.

## What makes StyLua for Roblox Studio special?

Preserve the formatting behavior that Studio users rely on as the plugin changes. Performance, reliability, and long-term maintainability are the priorities. Choose correctness and robustness over short-term convenience. No user-count claim is established by this repository.

### 1. Open at the core

StyLua for Roblox Studio publishes its source under MPL-2.0 in `LICENSE`. Keep changes and their reasoning reviewable in the repository. The repository does not establish a public roadmap or how many users run forks.

### 2. Performance without compromise

Keep Studio responsive while formatting scripts and rendering settings. Review the cost of formatter initialization, large inputs, React updates, and repeated UI work. This plugin has no WebSocket transport or CSS, but continuously repainting animations can still waste resources. Make sure all changes are considerate of performance impact.

### 3. Remote ready

Remote clients, relays, and tunnels do not apply here. Formatting runs inside Studio through the bundled formatter. Keep formatting independent of a running development server or network connection. Open Cloud tooling under `.lute/` publishes plugin assets and is separate from the formatting runtime.

### 4. Multi-surface

StyLua for Roblox Studio has one application client, the Studio plugin. Its Format toolbar action and Settings widget both need to remain usable.

**Web** does not apply. There is no hosted web app or local browser UI.

**Desktop** means Roblox Studio here. The plugin bundles its formatter and settings UI. Release and development builds have different plugin, toolbar, and widget identities. Studio does not host remote plugin clients.

**Mobile** does not apply. This repository has no mobile application or remote mobile control path.

## Maintainer guidance

Prefer ambitious ideas, simple systems, and software that feels obvious. Do not preserve complexity just because it already exists. Do not introduce machinery because it looks architecturally impressive. Understand the real constraint, then fight for the smallest model that makes the correct behavior unsurprising.

Channel both "measure twice, cut once" and "yagni". Fight scope creep. Try to honor the dev's intent in both a minimal and realistic fashion.

The rest of this document is meant to help you navigate the codebase and make changes effectively. Think of these instructions less as "hard rules", more as "good defaults". The developer's preferences should be able to override anything here.

The contributor may be using Studio while you work. Be careful about accessing scripts and settings, stopping Studio or Rojo processes, and replacing installed plugins. Never touch production, live databases, or daily-driver build or preview channels without explicit instructions. Name the target before taking an adjacent action.

Before writing code, read `general.md` and the relevant language file from the user's preferences directory. Use `~/.codex/preferences/` in Codex or `~/.claude/preferences/` in Claude Code. Resolve these paths from the user's home, never from this repository.

Treat questions as read-only requests. Answer first, even when the implied change is trivial, and ask before editing. Do not use subagents for ordinary work a single agent can finish in one pass. When parallel work is requested for breadth or review, state file ownership before starting.

## A small glossary

We need to be on the same page with terminology. When communicating, use this language:

- **you** means the agent reading this file and changing StyLua for Roblox Studio.
- **we, us, and maintainers** mean Morgan and the people building StyLua for Roblox Studio. These are who you are talking to now.
- **user** means the creator using the plugin to format scripts in Studio.
- **agent** means a coding agent working on this repository, including you. The plugin does not run coding agents.
- **provider** has no agent-runtime equivalent here. In UI code, `FoundationProvider` supplies Foundation context.
- **client** means the Roblox Studio plugin and its UI.
- **environment** means the checkout, tools, and Studio session used for development. There is no application server or server-owned database.
- **project** means this repository or the Rojo model in `plugin/default.project.json`, depending on context. There is no stored workspace record.
- **thread** is not a persisted plugin concept. The plugin has no durable conversation history.
- **turn** means a user-to-agent work cycle when discussing contributor work. The plugin has no agent turns or checkpoint refs.
- **plugin settings** means the JSON stored through `Plugin:GetSetting` and `Plugin:SetSetting` under `stylua-settings`. There is no application home or userdata directory.

## The three ways to hurt yourself

1. **Killing by pattern.** Never `pkill -f`, `pgrep | kill`, or `kill` a PID you found by matching a name, path, or worktree string. On Windows, never use `Stop-Process -Name` or pipe name-matched processes to `Stop-Process`. Your own agent process can have this worktree's path in its arguments, and other development sessions may be running. Kill only a PID you captured at spawn, or a confirmed owner of your port after verifying it belongs to your checkout. On Windows, inspect the owning PID with `Get-NetTCPConnection` and its command line with `Get-CimInstance Win32_Process` before stopping it.
2. **Writing to the live install.** Installed Studio plugins, plugin settings, and scripts in an open place are live user state. Do not replace, format, or clean them up without explicit instructions. Use copied source and an isolated test session instead. `lute run build --dev` distinguishes several UI identities, but `stylua-settings` is a fixed storage key. Do not assume complete settings isolation. `lute run upload-plugin` publishes a Creator Store asset, and pushing a `v*` tag triggers `.github/workflows/release.yml`. Neither is a local verification step.
3. **Baking in origins.** Vite HTTP and WebSocket origins and proxy routes do not apply because there is no web app. Preserve the underlying portability rule: do not bake local paths, localhost endpoints, or credentials into the plugin. Rojo sourcemaps can contain absolute paths and belong in ignored `plugin/generated/`.

## Hit every surface

A change can work on the path you tested and be missing elsewhere. Before calling frontend work done, walk this list and say which entries applied:

- **Entry points.** Format prefers `StudioService.ActiveScript` and otherwise formats selected `LuaSourceContainer` instances. Cover both paths. Settings changes must reach the formatter as well as the controls. There is no chat view, command palette, or registered keyboard action in this plugin.
- **Clients.** Studio is the only client. Check the release and development identities where relevant. Shared formatting logic lives in `plugin/src/Format/` and `plugin/src/StyLua/`.
- **Providers.** There are no coding-agent adapters. The shipped formatter uses Wasynth output in `plugin/wasm/`. Spider output in `plugin/wasm-spider/` is experimental and is not mapped into the plugin. For transpiler changes, decide which output and wrapper contracts apply, even if the decision is "not supported here".
- **Contracts.** There is no wire schema package. Keep the settings type, defaults, persisted JSON, UI controls, `buildConfig` conversion in `plugin/src/Format/init.luau`, and StyLua config and numeric mappings consistent.
- **Reverse states.** If you added a way in, add the way out and the way to see it. Closing Settings needs reopening. Changing settings needs reset. Formatting needs undo. A one-way door is a bug.
- **Connection modes.** Remote, relay, and tunnel modes do not apply. Local Studio sessions and multiple plugin instances still matter because toolbar coordination and settings depend on plugin identity.
- **Docs.** Check whether the change makes existing guidance inaccurate. Apply the [documentation rules](#documentation) before adding anything.

For non-trivial UI, layout, or product-copy changes, build several distinct static mocks before editing components. Publish them with the `html-communication` skill, report the URL, and wait for a pick. Follow Foundation guidance in `docs/ui/` for mocks and implementation. Design-system guidance takes precedence over the default of dark mode, a true black background, white primary text, dense layouts, and minimal copy. Avoid light-grey subtitle lines and decorative card or pill chrome unless Foundation calls for them. Do not use em dashes.

## Dev servers

- From the repository root, `rokit install` installs the tools pinned in `rokit.toml`, then `lute run setup` generates local files and installs Wally and Foundation packages. There is no automatic worktree setup hook. If package resolution fails, check setup first. `.lute/` contains the commands, but their working directory is the repository root.
- `lute run build --dev` writes `StyluaForRoblox-Dev.rbxm`; `lute run build` writes the release artifact `StyluaForRoblox.rbxm`. Neither starts a server or installs the artifact into Studio. Packages and generated files live in ignored `plugin/Packages/` and `plugin/generated/`. There is no application home override. Setup, install, codegen, and CI regenerate release-mode build config, so run the dev build after them when preparing an authorized dev installation.
- No worktree-derived port scheme exists. If a task requires a Rojo serve session, read its actual listening address from its output and track the process you started.
- Tailnet sharing, pairing URLs, reusable browser cookies, token scopes, and tunnel setup do not apply. There is no remote plugin client or pairing command. Do not configure a tunnel or consume another tool's pairing link as part of plugin development.
- There is no reusable web development credential or linked worktree `.env`. Open Cloud upload tooling reads `ROBLOX_API_KEY`, `ROBLOX_UNIVERSE_ID`, and `ROBLOX_PLACE_ID` from the environment only for an authorized upload. Never commit or publish credentials or authenticated URLs. No development-auth guide exists in this repository.
- Stop what you started, by the PID you tracked. See rule 1.

## Test data

An empty script is a poor test of a formatter change. Use representative copied Lua or Luau source and explicit settings instead of pointing at live Studio scripts. This plugin has no SQLite database or worktree data directory:

- Copy relevant source from this repository or use a user-authorized copy from a real project. Keep scratch fixtures outside the worktree and the installed plugin's settings store.
- SQLite `VACUUM INTO` does not apply here. For a local source fixture, create a separate directory and copy a representative module:

  ```powershell
  $fixtureDirectory = Join-Path -Path $env:TEMP -ChildPath ("stylua-fixtures-" + [guid]::NewGuid().ToString("N"))
  New-Item -ItemType Directory -Path $fixtureDirectory
  Copy-Item -LiteralPath "plugin/src/Settings/init.luau" -Destination $fixtureDirectory
  ```

  A plain file copy does not establish a consistent snapshot of a live database. If a future task involves SQLite, use a consistent read-only snapshot while its server is running. A plain copy requires the server to be stopped and the `-wal` and `-shm` files to be included. There are no such database files in the current plugin.

- Bring copied plugin settings only if the flow under test needs them. Local formatting tests do not need release credentials or production secrets.
- Copy in, never symlink. Data flows one way: into your sandbox, never back out.

## Verifying

- Smallest proof that the change works. Use targeted Selene and StyLua checks for the files you touched and the configured type analysis. For example, from the root, `selene plugin/src/Format/init.luau` and `stylua --check plugin/src/Format/init.luau` check that module. `lute run ci` supplies the Rojo sourcemap, Roblox definitions, ignore patterns, and editor settings for type analysis.
- Test meaningful logic or observable behavior. Do not render components to static markup to assert props or attributes, or add tests that merely assert callback wiring or mirror the implementation.
- **Run the required repo-wide check.** The existing project requirement takes precedence over the template's prohibition: `lute run ci` must pass before considering tasks completed. It runs Selene, StyLua, and luau-lsp and regenerates local files. Do not add unrelated full-suite runs. The checked-in GitHub workflows build artifacts and handle releases; they do not replace this static-analysis check. Report any existing failures explicitly rather than claiming a pass or silently waiving the requirement.
- Formatter, settings, and build-tool behavior changes ship with focused tests for that behavior. The current `lute run test` command is incomplete: `plugin/test.project.json` and `plugin/tests/runTests.server.luau` are absent, and `run-in-roblox` is not declared in `rokit.toml`. Do not report that command as a working test suite. If a change requires automated tests, account for the missing runner and fixtures in its scope.
- There is no event-sourced server, typed receipt stream, or worker-drain API here. Wait on the relevant completion result or Studio signal, never on sleeps or polling. A test that needs a timeout to pass is wrong.
- Upon request, user-visible frontend changes should get one integrated pass in an isolated Studio client. The primary agent does this once after integrating. Subagents do not launch their own Studio or Rojo sessions. Ask permission before doing computer use or spinning up browsers unless the user already explicitly authorized it. There are no repository-specific web or mobile verification skills.

Mobile native-client builds, Expo fingerprints, simulators, and Metro do not apply. For authorized Studio verification, a missing or outdated plugin artifact is a build step: run setup as needed and `lute run build --dev`, then install only into the authorized test session. There is no automated native-client installation helper in this repository.

## Pull requests

- Never make a PR unless the developer explicitly asks you to do so.
- Conventional commit titles, plain language: `fix: preserve scripts when formatting fails`. Use a scope when it helps identify the change, as recent `chore(deps)` and `ci(build-wasm)` commits do.
- Body: the problem in a sentence or two, then how you fixed it. End with the model and harness that did the work.
- UI changes need before/after images. Motion or timing needs a short video.
- Upload PR evidence to GitHub. Never commit PR-only screenshots or assets such as `.github/pr-assets/`.
- One concern per PR. If the description says "also", split it.
- When babysitting: poll checks and comments newer than the last push, verify each bot finding against the source, fix real ones, dismiss false positives with a written reason. Stay quiet when nothing is new. Stop when the bots are green on the latest commit.
- Open a real PR, not a draft, so review bots run. Rebase onto the latest `main` before opening.
- Fix CI failures while babysitting, distinguishing real breaks from known infrastructure flakes. Merge only when the request gives that disposition. Otherwise, report the result and ask.

## Documentation

Most code changes do not need an internal documentation change. Agents can read the code.

- Internal guidance belongs with the relevant material in `docs/process/`; there is no `docs/internals/` directory. Reserve architectural documentation for decisions and their reasons, constraints that span components, and implementation traps that are hard to discover from the source. Before adding a paragraph, ask what a maintainer would get wrong without it. If reading the relevant code answers the question, leave it out.
- Do not document every feature, enumerate fields or methods, narrate control flow, maintain file catalogs, or append PR summaries. Types, tests, and code already record the implementation. The glossary defines shared vocabulary; it is not a feature index.
- Keep a local implementation explanation in a nearby code comment. Use an internal doc when the reasoning crosses boundaries or needs context the code cannot carry well. Link to the relevant source instead of copying it.
- When a documented decision or constraint changes, rewrite or remove the affected text. Do not append another account of the new behavior. A new internal page needs a distinct, durable reason to exist.
- `README.md` is the entry point for user guidance; there is no `docs/user/` directory. Give each major feature a concise section explaining what it does, how to start, and anything unintuitive when user documentation is needed. A settings path is useful; descriptions of visible buttons, icons, layouts, animations, or every UI state are not. Before adding text, ask what task or decision it helps the user with.
- Keep user docs in the shipped product's voice, without implementation details or contributor tooling. Update the relevant feature section when how to use it changes. A UI tweak does not need a documentation entry, and a new control does not need its own page.
- There is no `docs/operations/` directory. The development commands above, `.lute/` commands, and `.github/workflows/` define the current setup and release procedures. Keep any new maintainer setup, release, or debugging guidance separate from user tasks. Instructions for using the installed Studio plugin belong in user guidance.
- Apply the `unslop` skill to replies, documentation, commit messages, PR descriptions, and code comments. Read it once per session. Do not use em dashes.

## Plans and work artifacts

- Do not commit implementation plans, research notes, or agent scratch files. Keep temporary working material outside the worktree. `.plans/` is not gitignored here, so it is not a safety net.
- Track active maintainer work in the GitHub issue or project item that owns it. There is no `CONTRIBUTING.md` or documented Ideas-discussion process. Use the existing tracking item for the task and follow maintainer direction for external proposals.
- A merged PR is the implementation record. Close or update its tracking item when the work lands; do not preserve a second checklist in the repository.

## How it works

`plugin/bin/Main.plugin.luau` calls `setupPlugin`, which creates the shared toolbar and settings widget and registers cleanup. Format reads editor source, converts settings to StyLua configuration, calls the bundled formatter through the wrapper in `plugin/src/StyLua/`, and applies changed output through `ScriptEditorService:UpdateSourceAsync` with a change-history waypoint. Formatting errors warn without replacing source. Charm holds settings, React and Foundation render the controls, and plugin settings persist JSON. There is no WebSocket protocol, event log, projector, provider subprocess, reactor, receipt stream, or hidden Git checkpoint.

The glossary above defines the local terminology. There is no separate glossary file. See `plugin/src/Plugin/setupPlugin.luau`, `plugin/src/Format/init.luau`, and `plugin/src/Settings/init.luau` for the runtime flow.

## Where code lives

- `plugin/bin/` and `plugin/src/Plugin/` contain startup, toolbar coordination, widget mounting, plugin state, and cleanup. There is no server or Effect code, so the template's Effect reference does not apply.
- `plugin/src/App.luau` and `plugin/src/Settings/SettingsScreen.luau` contain the React and Foundation UI. There are no separate web, Electron, mobile, or marketing apps. Read `docs/process/react-patterns.md` and the relevant `docs/ui/` reference before changing UI code.
- `plugin/src/Settings/init.luau` and `plugin/src/StyLua/init.luau` export the settings and formatter types. There is no separate contracts package. Keep type definitions and small conversion helpers free of unrelated runtime logic.
- `.lute/lib/` and `.lute/utils/` contain CLI support code. There is no shared application package or subpath-export system. Keep helpers narrow and use direct module imports instead of adding barrels.
- `plugin/src/Format/` and `plugin/src/StyLua/` connect Studio source editing to the bundled formatter. There is no shared web/mobile client runtime. `plugin/wasm/` is generated Wasynth output used by Rojo; `plugin/wasm-spider/` is generated experimental output. Regenerate through the relevant workflow's build steps rather than hand-editing either output. Do not dispatch a workflow as a local check: the WASM workflow commits and opens PRs, and the Spider workflow commits output.
- `.repos/` is ignored but contains no checked-in references or sync command. Treat any local reference checkout as read-only: prefer its patterns over invented ones, and never edit or import from it. Dependencies belong in `plugin/Packages/`; refresh them with `lute run install` when changing dependencies. Keep generated files in `plugin/generated/` and change their sources in `.lute/commands/codegen/` rather than editing the output.

## Taste

- Complexity belongs at the adapter boundary. Orchestration stays pure, UI stays dumb.
- Infer internal types where possible. Fully type publicly exposed Luau functions, including parameters and return values. `any` is the enemy.
- Comments describe how a thing is used, and move when the code moves. To be used mostly to describe functions, not to annotate every line of behavior.
- Our users work in Studio and notice a dropped frame, a misleading progress indicator, and a stale label. No continuously repainting animations; they peg the GPU on high-refresh displays.
- If a rule here fights the task in front of you, say so loudly and get a human sign-off before breaking it.

Maintainability is a first-class priority, not a clean-up step. Hold every change to these rules:

- **Extract shared logic before adding new code.** Before writing functionality, check whether it already exists or can be generalized from existing code. Duplicate logic across multiple files is a code smell.
- **Change existing code.** Don't add a local copy of logic that already lives elsewhere. Refactor the shared module so both callers use it. Don't take shortcuts.
- **One file per library function.** Keep utility modules narrow, as with `plugin/src/Plugin/PluginStore/createPluginStore.luau`. Group related single-responsibility modules in a folder. Don't build catch-all `Helpers` or `Utils` modules.
- **Separate modules, not in-file tricks.** Use sibling files to isolate state and responsibilities. Don't fake module boundaries with `do`-blocks or IIFE-style closures.
- **Reduce coupling.** Avoid module-level mutable state that multiple free functions read and write. If a module has two or more independent units of state, split them into sibling modules with explicit APIs.
- **Reduce spaghetti.** Control flow should be readable from a function's arguments and return values, not from tracing side effects through shared state in other helpers.

Apply the existing design principles:

- **KISS (Keep It Simple, Stupid).** Prefer straightforward solutions. Avoid over-engineering and unnecessary complexity. Readable, maintainable code beats clever code.
- **YAGNI (You Aren't Gonna Need It).** Implement only what's needed now. Don't add speculative features, options, or abstractions for hypothetical future needs.
- **SOLID.** Apply the five principles when shaping modules and interfaces:
  - *Single Responsibility*. Each module has one reason to change.
  - *Open-Closed*. Extend behavior without modifying existing code where an existing extension point fits. This does not prohibit refactoring shared code to remove duplication.
  - *Liskov Substitution*. Subtypes honor the contracts of their base types.
  - *Interface Segregation*. Callers depend only on the interface they use.
  - *Dependency Inversion*. Depend on abstractions, not concrete implementations.

Use the user-level Luau preferences and `docs/process/react-patterns.md` for language and React conventions. User preferences take precedence over examples in local guides, including the allowance for concise usage comments and the prohibition on continuously repainting animations.

## Additional tips

- Don't verify with browsers or computer use unless the user explicitly agrees or requests it.
- Security is important, but should not be over-indexed on, especially for dev mode/maintainer-only features.
