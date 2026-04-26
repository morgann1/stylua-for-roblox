--!strict

local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local DoCleanup = require(StyluaForRoblox.Packages.DoCleanup)
local Interposer = require(StyluaForRoblox.Packages.Interposer)
local Leader = require(StyluaForRoblox.Packages.Leader)
local SharedToolbar = require(StyluaForRoblox.Packages.SharedToolbar)
local buildConfig = require(StyluaForRoblox.Generated.buildConfig)
local formatAsync = require(StyluaForRoblox.Source.Format)
local mountApp = require(StyluaForRoblox.Source.Plugin.mountApp)
local PluginStore = require(StyluaForRoblox.Source.Plugin.PluginStore)

local WIDGET_INFO = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 320, 210, 300, 210)

local PROTOCOL_NAMESPACE = "@morgann1/stylua-for-roblox"
local TOOLBAR_ID = "stylua-for-roblox"

local function iconRamp(variants: { light: string, dark: string, mono: string })
	return {
		{
			size = 64,
			variants = {
				light = variants.light,
				dark = variants.dark,
				mono = variants.mono,
			} :: { ["light" | "dark" | "mono"]: string },
		},
	}
end

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
		destroyApp = mountApp(plugin, widget)
	end

	local settingsButtonId = `{buildConfig.buttonId}-settings`
	local formatButtonId = `{buildConfig.buttonId}-format`

	local scope: { unknown } = {}

	local interposer = Interposer.logon(buildConfig.mediumName, buildConfig.mediumName, scope)
	local leader = Leader.track(scope, interposer)

	local toolbar = SharedToolbar.connect(
		scope,
		plugin,
		buildConfig.mediumName,
		interposer,
		leader,
		PROTOCOL_NAMESPACE,
		TOOLBAR_ID,
		buildConfig.toolbarTitle,
		buildConfig.peerId,
		{
			[formatButtonId] = {
				displayName = "Format",
				toolTip = "Format the active script with StyLua",
				iconRamp = iconRamp({
					light = "rbxassetid://114496818486448",
					dark = "rbxassetid://139507476070594",
					mono = "rbxassetid://88819650709811",
				}),
				clickableWhenViewportHidden = true,
				creationOrder = 0,
			},
			[settingsButtonId] = {
				displayName = "Settings",
				toolTip = "Open StyLua settings",
				iconRamp = iconRamp({
					light = "rbxassetid://133638526545460",
					dark = "rbxassetid://73058425827242",
					mono = "rbxassetid://112604258400921",
				}),
				clickableWhenViewportHidden = true,
				creationOrder = 1,
			},
		},
		{}
	)

	table.insert(
		scope,
		toolbar.onClick(function(buttonId: string)
			if buttonId == formatButtonId then
				formatAsync()
			elseif buttonId == settingsButtonId then
				widget.Enabled = not widget.Enabled
			end
		end)
	)

	local function setActiveIfLeader(isActive: boolean)
		if leader.selfIsLeader() == true then
			toolbar.setActive(settingsButtonId, isActive)
		end
	end

	local enabledConn = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		setActiveIfLeader(widget.Enabled)
		if widget.Enabled then
			mount()
		end
	end)

	if widget.Enabled then
		setActiveIfLeader(true)
		mount()
	end

	plugin.Unloading:Connect(function()
		enabledConn:Disconnect()
		DoCleanup(scope)
		if destroyApp ~= nil then
			destroyApp()
			destroyApp = nil
		end
	end)
end

return setupPlugin
