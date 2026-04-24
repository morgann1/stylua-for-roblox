# StyLua for Studio

A Roblox Studio plugin that runs [StyLua](https://github.com/JohnnyMorganz/StyLua) entirely in-process, with no external binary, by compiling StyLua's Rust crate to WebAssembly and transpiling that WASM to Luau via [Spider](https://github.com/SovereignSatellite/Spider).

## Status

`WIP` — blocked on Spider.

StyLua compiles to `wasm32-unknown-unknown` cleanly. The blocker is the WASM → Luau transpile step: Spider's WebAssembly lifter panics on StyLua's output with `Option::unwrap()` on `None` inside `Sources/WebAssembly/Lifter/src/control_flow.rs` (specifically at `path.graph.find_branch_end(last).unwrap()`). The panic reproduces with and without `--optimize`, so it's a lifter issue, not an optimizer pass. Waiting on upstream Spider to stabilize its lifter before trying again.