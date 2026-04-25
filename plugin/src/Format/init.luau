--!strict

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local Settings = require(StyluaForRoblox.Source.Settings)
local StyLua = require(StyluaForRoblox.Source.StyLua)

local SPACE_AFTER_FN_INT: { [Settings.SpaceAfterFunctionNames]: number } = {
	Never = 0,
	Definitions = 1,
	Calls = 2,
	Always = 3,
}

local function buildConfig(settings: Settings.Settings): StyLua.Config
	return {
		columnWidth = settings.columnWidth,
		indentWidth = settings.indentWidth,
		indentType = settings.indentType,
		lineEndings = settings.lineEndings,
		quoteStyle = settings.quoteStyle,
		callParentheses = settings.callParentheses,
		collapseSimpleStatement = settings.collapseSimpleStatement,
		spaceAfterFunctionNames = SPACE_AFTER_FN_INT[settings.spaceAfterFunctionNames],
		sortRequires = settings.sortRequires.enabled,
		blockNewlineGaps = settings.blockNewlineGaps == "Preserve",
		syntax = settings.syntax,
	}
end

local function formatScriptAsync(script: LuaSourceContainer)
	local source = ScriptEditorService:GetEditorSource(script)
	local config = buildConfig(Settings.settings())

	local ok, result = pcall(StyLua.format, source, config)
	if not ok then
		warn(`[StyLua] format error in {script:GetFullName()}: {result}`)
		return
	end

	local formatted = result :: string
	if formatted == source then
		return
	end

	ScriptEditorService:UpdateSourceAsync(script, function()
		return formatted
	end)
	ChangeHistoryService:SetWaypoint("StyLua")
end

local function formatAsync()
	local active = StudioService.ActiveScript
	if active ~= nil then
		formatScriptAsync(active)
		return
	end

	for _, instance in Selection:Get() do
		if instance:IsA("LuaSourceContainer") then
			formatScriptAsync(instance)
		end
	end
end

return formatAsync
