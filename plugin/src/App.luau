--!strict

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local Foundation = require(StyluaForRoblox.Packages.Foundation)
local React = require(StyluaForRoblox.Packages.React)
local SettingsScreen = require(StyluaForRoblox.Source.Settings.SettingsScreen)

local e = React.createElement

export type Props = {
	plugin: Plugin,
	overlayGui: DockWidgetPluginGui,
}

local function App(props: Props)
	return e(Foundation.FoundationProvider, {
		overlayGui = props.overlayGui,
	}, {
		SettingsScreen = e(SettingsScreen),
	})
end

return App
