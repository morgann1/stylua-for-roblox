# StyLua for Studio

[![Build WASM](https://github.com/morgann1/stylua-for-roblox/actions/workflows/build-wasm.yml/badge.svg)](https://github.com/morgann1/stylua-for-roblox/actions/workflows/build-wasm.yml)
[![Release](https://github.com/morgann1/stylua-for-roblox/actions/workflows/release.yml/badge.svg)](https://github.com/morgann1/stylua-for-roblox/actions/workflows/release.yml)
[![Latest release](https://img.shields.io/github/v/release/morgann1/stylua-for-roblox)](https://github.com/morgann1/stylua-for-roblox/releases/latest)
[![License: MPL-2.0](https://img.shields.io/badge/license-MPL--2.0-blue)](LICENSE)

In-process [StyLua](https://github.com/JohnnyMorganz/StyLua) for Roblox Studio. No companion server, no CLI binary, no `HttpService` round-trip.

<!-- LAST_CHECKED:START -->
_Last checked against upstream: 2026-04-26 18:19 UTC (StyLua v2.4.1)_
<!-- LAST_CHECKED:END -->

## Overview

StyLua's Rust crate gets compiled to WebAssembly, and the WASM gets transpiled to Luau via [Wasynth](https://github.com/Rerumu/Wasynth). That blob ships inside the plugin's `.rbxm` and runs in the same process as the editor. To format, the plugin reads source via `ScriptEditorService:GetEditorSource`, runs StyLua, and writes the result back through `UpdateSourceAsync` with a `ChangeHistoryService` waypoint, so Ctrl+Z undoes a format like any other edit.

## Motivation

Existing in-Studio StyLua plugins want a Node.js sidecar running alongside Studio that proxies HTTP requests to the StyLua CLI binary. So you install Node, install StyLua, and start the sidecar before every Studio session. The plugin also only formats while the sidecar is alive. Folding the formatter into the plugin removes all of that. The WASM-transpiled StyLua ships inside the `.rbxm`, so install is one click and there's no second process to keep running.

The other thing is staying current. StyLua ships frequent releases, and any drift between the version embedded in the plugin and upstream is a behavior bug from the user's perspective. A scheduled GitHub workflow checks `JohnnyMorganz/StyLua` every 6 hours and opens a PR when a new tag lands, with the regenerated `plugin/wasm/StyLua.luau`, an updated `stylua.version`, a semver-passthrough bump in `plugin/wally.toml`, and a fresh `CHANGELOG.md` section. Review, merge, tag, ship.

## Usage

Install the latest `StyluaForRoblox.rbxm` from the [Releases](https://github.com/morgann1/stylua-for-roblox/releases) page (drop into `%LOCALAPPDATA%\Roblox\Plugins` on Windows, or use the **Plugins Folder** shortcut from Studio's Plugins tab).

The plugin adds two buttons to the Studio toolbar.

### Format

Formats the active script with the current settings. If no script is active, formats every `LuaSourceContainer` in your Selection.

```text
Toolbar → StyLua → Format        (or formats the Selection if no script is open)
```

The formatted source goes through `ScriptEditorService:UpdateSourceAsync` and stamps a `ChangeHistoryService` waypoint, so Ctrl+Z reverts a format in one step.

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

There's no project-level `stylua.toml` lookup yet. Every script formats against the global plugin settings.

## Acknowledgements

- [**StyLua**](https://github.com/JohnnyMorganz/StyLua): the formatter itself. Everything this plugin does is a thin wrapper around StyLua's Rust crate.
- [**Wasynth**](https://github.com/Rerumu/Wasynth): the WASM-to-Luau transpiler that lets us ship StyLua without a native binary.
- [**Foundation**](https://github.com/Roblox/foundation): the React component library backing the settings UI.
- [**Lute**](https://github.com/luau-lang/lute): the Luau runtime powering the build, format, and release scripts under `.lute/`.
- [**Rojo**](https://github.com/rojo-rbx/rojo): both for the project file format that produces the `.rbxm` and for the settings-page layout pattern this plugin borrows from.

## License

This project is licensed under the [MPL-2.0 license](LICENSE), matching upstream StyLua, since the published `.rbxm` embeds StyLua's compiled output. Third-party code carries its own licenses: StyLua (MPL-2.0), Wasynth (MIT), Foundation (Apache-2.0), Lute (MIT).
