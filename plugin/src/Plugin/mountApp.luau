--!strict

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local App = require(StyluaForRoblox.Source.App)
local React = require(StyluaForRoblox.Packages.React)
local ReactRoblox = require(StyluaForRoblox.Packages.ReactRoblox)

local e = React.createElement

local function mountApp(plugin: Plugin, widget: DockWidgetPluginGui): () -> ()
	local container = Instance.new("Folder")
	local root = ReactRoblox.createRoot(container)

	root:render(ReactRoblox.createPortal(
		e(App, {
			plugin = plugin,
			overlayGui = widget,
		}),
		widget
	))

	return function()
		root:unmount()
		container:Destroy()
	end
end

return mountApp
