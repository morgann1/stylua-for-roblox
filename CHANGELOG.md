# Changelog

All notable changes to StyLua for Studio are documented in this file.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-25

### ✨ New
- Format toolbar button runs StyLua on the active script (or every `LuaSourceContainer` in Selection if there's no active script). Uses `ScriptEditorService:GetEditorSource` / `UpdateSourceAsync` and stamps a `ChangeHistoryService` waypoint so the format is undoable.
- Settings dock widget with a Rojo-style row layout (bold name, wrapping description, right-aligned control, divider) backed by Foundation. Settings persist to plugin storage and mirror StyLua's Config schema (syntax, column width, indent, quote style, call parentheses, collapse simple statements, block newline gaps, sort requires, space after function names, line endings).
- StyLua runs entirely in-process: the upstream Rust crate is compiled to WebAssembly and transpiled to Luau via [Wasynth](https://github.com/Rerumu/Wasynth). No external server, binary, or HTTP request.
- Scheduled GitHub workflow checks `JohnnyMorganz/StyLua` every 6 hours and rebuilds `plugin/wasm/StyLua.luau` when a new tag lands. README carries a `Last checked against upstream` stamp refreshed on every check.
