--!strict

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local React = require(StyluaForRoblox.Packages.React)

local e = React.createElement

export type Props = {
	plugin: Plugin,
	overlayGui: DockWidgetPluginGui,
}

local function App(_props: Props)
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Label = e("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "StyLua for Roblox",
			TextScaled = true,
			Font = Enum.Font.GothamMedium,
			TextColor3 = Color3.fromRGB(220, 220, 220),
		}),
	})
end

return App
