# StyLua for Studio

A Roblox Studio plugin that runs [StyLua](https://github.com/JohnnyMorganz/StyLua) entirely in-process, with no external binary, by compiling StyLua's Rust crate to WebAssembly and transpiling that WASM to Luau via [Spider](https://github.com/SovereignSatellite/Spider).

## Status

`WIP` — blocked on Spider.

StyLua compiles to `wasm32-unknown-unknown` cleanly. The blocker is the WASM → Luau transpile step: Spider's WebAssembly lifter panics on StyLua's output with `Option::unwrap()` on `None` inside `Sources/WebAssembly/Lifter/src/control_flow.rs` (specifically at `path.graph.find_branch_end(last).unwrap()`). The panic reproduces with and without `--optimize`, so it's a lifter issue, not an optimizer pass. Waiting on upstream Spider to stabilize its lifter before trying again.

## How the build works

`.github/workflows/build-wasm.yml` is a `workflow_dispatch`-only pipeline that:

1. Reads the latest StyLua release tag and the currently built version (`plugin/generated/stylua.version` via the contents API) and decides whether to rebuild.
2. Checks out StyLua at that tag, installs the Rust toolchain with the `wasm32-unknown-unknown` target, and builds `stylua_lib.wasm` with all Lua feature flags enabled (`lua52,lua53,lua54,luajit,luau,cfxlua`).
3. Installs `spider-cli` from source and transpiles the `.wasm` to `plugin/generated/stylua.luau`.
4. Commits `plugin/generated/stylua.{luau,version}` back to `main`.

Dispatch manually with `gh workflow run build-wasm.yml` (optionally `-f force=true` to rebuild at the same tag).

## Layout

- `plugin/` — Rojo project (`default.project.json`) for the Studio plugin itself.
- `plugin/src/` — plugin source (Luau).
- `plugin/generated/` — output of the WASM pipeline (`stylua.luau`, `stylua.version`).
- `.github/workflows/build-wasm.yml` — the build pipeline described above.
