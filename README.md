# StyLua for Studio

A Roblox Studio plugin that runs [StyLua](https://github.com/JohnnyMorganz/StyLua) entirely in-process, with no external binary, by compiling StyLua's Rust crate to WebAssembly and transpiling that WASM to Luau via [Spider](https://github.com/SovereignSatellite/Spider).

## Status

**WIP:** Spider currently panics on StyLua's WASM output.