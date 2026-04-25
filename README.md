# StyLua for Studio

[![Build WASM](https://github.com/morgann1/stylua-for-roblox/actions/workflows/build-wasm.yml/badge.svg)](https://github.com/morgann1/stylua-for-roblox/actions/workflows/build-wasm.yml)
[![Release](https://github.com/morgann1/stylua-for-roblox/actions/workflows/release.yml/badge.svg)](https://github.com/morgann1/stylua-for-roblox/actions/workflows/release.yml)
[![Latest release](https://img.shields.io/github/v/release/morgann1/stylua-for-roblox)](https://github.com/morgann1/stylua-for-roblox/releases/latest)
[![License: MPL-2.0](https://img.shields.io/badge/license-MPL--2.0-blue)](LICENSE)

In-process [StyLua](https://github.com/JohnnyMorganz/StyLua) for Roblox Studio. No companion server, no CLI binary, no `HttpService` round-trip.

<!-- LAST_CHECKED:START -->
_Last checked against upstream: never_
<!-- LAST_CHECKED:END -->

## Overview

The upstream StyLua Rust crate is compiled to WebAssembly and the WASM is transpiled to Luau via [Wasynth](https://github.com/Rerumu/Wasynth), so the formatter ships inside the plugin's `.rbxm` and runs in the same process as the editor. The plugin reads source through `ScriptEditorService:GetEditorSource`, hands it to StyLua, and applies the result via `UpdateSourceAsync` with a `ChangeHistoryService` waypoint, so a format is undone like any other edit.

## Motivation

Existing in-Studio formatters either shell out to a local HTTP server backed by the StyLua CLI or paste source into a hosted formatter and read the result back. Both options break offline, both depend on a binary the plugin can't ship, and both move script source through a process the user has to trust. Folding the formatter into the plugin removes that boundary.

The other axis is staying current — StyLua ships frequent releases and any drift between the embedded version and upstream is a behavior bug from the user's perspective. A scheduled GitHub workflow checks `JohnnyMorganz/StyLua` every 6 hours and opens a PR when a new tag lands, with the regenerated `plugin/wasm/StyLua.luau`, an updated `stylua.version`, a semver-passthrough bump in `plugin/wally.toml`, and a fresh `CHANGELOG.md` section. Review, merge, tag, ship.

## Usage

Install the latest `StyluaForRoblox.rbxm` from the [Releases](https://github.com/morgann1/stylua-for-roblox/releases) page (drop into `%LOCALAPPDATA%\Roblox\Plugins` on Windows, or use the **Plugins Folder** shortcut from Studio's Plugins tab).

The plugin adds two buttons to the Studio toolbar:

### Format

Formats the active script with the current settings. If no script is active, formats every `LuaSourceContainer` in your Selection.

```text
Toolbar → StyLua → Format        (or formats the Selection if no script is open)
```

The formatted source is applied through `ScriptEditorService:UpdateSourceAsync` and stamps a `ChangeHistoryService` waypoint, so `Ctrl+Z` reverts a format in one step.

### Settings

Toggles a dock widget exposing every StyLua config field. Changes apply on the next Format and persist per Studio install via `plugin:GetSetting` / `plugin:SetSetting`.

| Setting                    | Type   | StyLua field                 |
| -------------------------- | ------ | ---------------------------- |
| Syntax                     | enum   | `syntax`                     |
| Column width               | number | `column_width`               |
| Indent type                | enum   | `indent_type`                |
| Indent width               | number | `indent_width`               |
| Quote style                | enum   | `quote_style`                |
| Call parentheses           | enum   | `call_parentheses`           |
| Collapse simple statements | enum   | `collapse_simple_statement`  |
| Block newline gaps         | enum   | `block_newline_gaps`         |
| Sort requires              | toggle | `sort_requires.enabled`      |
| Line endings               | enum   | `line_endings`               |
| Space after function names | enum   | `space_after_function_names` |

There's no project-level `stylua.toml` lookup yet — every script formats against the global plugin settings.

## Acknowledgements

- [**StyLua**](https://github.com/JohnnyMorganz/StyLua) — the formatter itself. Everything this plugin does is ultimately a thin wrapper around StyLua's Rust crate.
- [**Wasynth**](https://github.com/Rerumu/Wasynth) — the WASM-to-Luau transpiler that lets us ship StyLua without a native binary.
- [**Foundation**](https://github.com/Roblox/foundation) — the React component library backing the settings UI.
- [**Lute**](https://github.com/luau-lang/lute) — the Luau runtime powering the build, format, and release scripts under `.lute/`.
- [**Rojo**](https://github.com/rojo-rbx/rojo) — both for the project file format that produces the `.rbxm` and for the settings-page layout pattern this plugin borrows from.

## License

This project is licensed under the terms of the [MPL-2.0 license](LICENSE), matching upstream StyLua, since the published `.rbxm` embeds StyLua's compiled output. Third-party code carries its own licenses: StyLua (MPL-2.0), Wasynth (MIT), Foundation (Apache-2.0), Lute (MIT).
