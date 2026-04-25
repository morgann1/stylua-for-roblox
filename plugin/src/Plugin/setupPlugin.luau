--!strict

local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local PluginStore = require(StyluaForRoblox.Source.Plugin.PluginStore)
local SharedToolbar = require(StyluaForRoblox.Packages.SharedToolbar)
local buildConfig = require(StyluaForRoblox.Generated.buildConfig)

local WIDGET_INFO = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 936, 702, 306, 306)

local function setupPlugin(plugin: Plugin): ()
	if RunService:IsRunning() then
		return
	end

	if StudioService:GetUserId() == 0 then
		warn("[StyLua] Studio is not signed in (GetUserId == 0); plugin will not initialize")
		return
	end

	plugin.Name = buildConfig.pluginName

	PluginStore.get().setPlugin(plugin)

	local widget = plugin:CreateDockWidgetPluginGuiAsync(buildConfig.widgetId, WIDGET_INFO)
	widget.Title = buildConfig.widgetTitle
	widget.Name = buildConfig.widgetName
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local destroyApp: (() -> ())? = nil

	local function mount()
		if destroyApp ~= nil then
			return
		end
		local mountApp = require(StyluaForRoblox.Source.Plugin.mountApp)
		destroyApp = mountApp(plugin, widget)
	end

	local settingsButtonId = `{buildConfig.buttonId}-settings`
	local formatButtonId = `{buildConfig.buttonId}-format`

	local handle = SharedToolbar.register({
		plugin = plugin,
		mediumName = buildConfig.mediumName,
		toolbarTitle = buildConfig.toolbarTitle,
		peerId = buildConfig.peerId,
		buttons = {
			{
				id = formatButtonId,
				title = "Format",
				tooltip = "Format the active script with StyLua",
				iconId = "rbxassetid://100834953677262",
				clickableWhenViewportHidden = false,
				onClick = function()
					-- TODO: read StudioService.ActiveScript, run StyLua, write back
					warn("[StyLua] Format Document not yet implemented")
				end,
			},
			{
				id = settingsButtonId,
				title = "Settings",
				tooltip = "Open StyLua settings",
				iconId = "rbxassetid://78359725093269",
				clickableWhenViewportHidden = true,
				onClick = function()
					widget.Enabled = not widget.Enabled
				end,
			},
		},
	})

	local enabledConn = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		handle:setActive(settingsButtonId, widget.Enabled)
		if widget.Enabled then
			mount()
		end
	end)

	if widget.Enabled then
		handle:setActive(settingsButtonId, true)
		mount()
	end

	plugin.Unloading:Connect(function()
		enabledConn:Disconnect()
		handle:destroy()
		if destroyApp ~= nil then
			destroyApp()
			destroyApp = nil
		end
	end)
end

return setupPlugin
