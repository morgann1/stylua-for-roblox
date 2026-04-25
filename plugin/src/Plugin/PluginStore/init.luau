--!strict

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local Charm = require(StyluaForRoblox.Packages.Charm)

local createPluginStore = require(script.createPluginStore)

return table.freeze({
	get = Charm.computed(createPluginStore),
})
