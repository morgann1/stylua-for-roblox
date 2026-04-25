# StyLua for Studio

A Roblox Studio plugin that runs [StyLua](https://github.com/JohnnyMorganz/StyLua) entirely in-process, with no external binary, by compiling StyLua's Rust crate to WebAssembly and transpiling that WASM to Luau via [Wasynth](https://github.com/Rerumu/Wasynth).

## Status

**WIP:** Wasynth transpile pipeline not yet validated against StyLua's WASM output.
