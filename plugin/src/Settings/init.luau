--!strict

local HttpService = game:GetService("HttpService")

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local Charm = require(StyluaForRoblox.Packages.Charm)
local PluginStore = require(StyluaForRoblox.Source.Plugin.PluginStore)
local React = require(StyluaForRoblox.Packages.React)

local STORAGE_KEY = "stylua-settings"

export type LuaVersion = "All" | "Lua51" | "Lua52" | "Lua53" | "Lua54" | "Luau" | "LuaJIT" | "CfxLua"
export type IndentType = "Tabs" | "Spaces"
export type LineEndings = "Unix" | "Windows"
export type QuoteStyle = "AutoPreferDouble" | "AutoPreferSingle" | "ForceDouble" | "ForceSingle"
export type CallParenType = "Always" | "NoSingleString" | "NoSingleTable" | "None" | "Input"
export type CollapseSimpleStatement = "Never" | "FunctionOnly" | "ConditionalOnly" | "Always"
export type BlockNewlineGaps = "Never" | "Preserve"
export type SpaceAfterFunctionNames = "Never" | "Definitions" | "Calls" | "Always"

export type Settings = {
	syntax: LuaVersion,
	columnWidth: number,
	lineEndings: LineEndings,
	indentType: IndentType,
	indentWidth: number,
	quoteStyle: QuoteStyle,
	callParentheses: CallParenType,
	collapseSimpleStatement: CollapseSimpleStatement,
	blockNewlineGaps: BlockNewlineGaps,
	sortRequires: { enabled: boolean },
	spaceAfterFunctionNames: SpaceAfterFunctionNames,
}

local DEFAULTS: Settings = {
	syntax = "Luau",
	columnWidth = 120,
	lineEndings = "Unix",
	indentType = "Tabs",
	indentWidth = 4,
	quoteStyle = "AutoPreferDouble",
	callParentheses = "Always",
	collapseSimpleStatement = "Never",
	blockNewlineGaps = "Never",
	sortRequires = { enabled = false },
	spaceAfterFunctionNames = "Never",
}

local settingsAtom = Charm.atom(DEFAULTS)
local hasLoaded = false

local function mergeWithDefaults(input: any): Settings
	local merged: any = table.clone(DEFAULTS :: any)
	if typeof(input) ~= "table" then
		return merged :: Settings
	end
	for key in (DEFAULTS :: any) :: { [string]: any } do
		local stored = (input :: any)[key]
		if stored == nil then
			continue
		end
		if key == "sortRequires" and typeof(stored) == "table" then
			merged[key] = {
				enabled = if typeof(stored.enabled) == "boolean" then stored.enabled else false,
			}
		else
			merged[key] = stored
		end
	end
	return merged :: Settings
end

Charm.effect(function()
	local plugin = PluginStore.get().getPlugin()
	if plugin == nil or hasLoaded then
		return
	end
	hasLoaded = true

	local raw = plugin:GetSetting(STORAGE_KEY)
	if typeof(raw) ~= "string" then
		return
	end

	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not ok then
		return
	end

	settingsAtom(mergeWithDefaults(decoded))
end)

local previous: Settings = DEFAULTS
Charm.effect(function()
	local current = settingsAtom()
	local plugin = PluginStore.get().getPlugin()
	if plugin == nil or not hasLoaded then
		previous = current
		return
	end
	if current == previous then
		return
	end
	previous = current

	task.spawn(function()
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode(current)
		end)
		if ok then
			pcall(plugin.SetSetting, plugin, STORAGE_KEY, encoded)
		end
	end)
end)

local function update(partial: { [string]: any })
	settingsAtom(function(prev: Settings): Settings
		local merged: any = table.clone(prev :: any)
		for key, value in partial do
			merged[key] = value
		end
		return merged :: Settings
	end)
end

local function reset()
	settingsAtom(DEFAULTS)
end

local function useSettings(): Settings
	local value, setValue = React.useState(settingsAtom())
	React.useEffect(function()
		setValue(settingsAtom())
		return Charm.subscribe(settingsAtom, function(next)
			setValue(next)
		end)
	end, {})
	return value
end

return {
	defaults = DEFAULTS,
	settings = settingsAtom,
	update = update,
	reset = reset,
	useSettings = useSettings,
}
