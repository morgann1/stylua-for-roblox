# StyLua for Studio

<!-- LAST_CHECKED:START -->
_Last checked against upstream: 2026-04-25 22:46 UTC (StyLua v2.4.1)_
<!-- LAST_CHECKED:END -->

A Roblox Studio plugin that runs [StyLua](https://github.com/JohnnyMorganz/StyLua) entirely in-process, with no external binary, by compiling StyLua's Rust crate to WebAssembly and transpiling that WASM to Luau via [Wasynth](https://github.com/Rerumu/Wasynth).