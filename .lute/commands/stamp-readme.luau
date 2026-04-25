--!strict

local fs = require("@lute/fs")
local process = require("@lute/process")

local stampReadme = {}

stampReadme.name = "stamp-readme"
stampReadme.description = "Refreshes the README's last-checked-against-upstream timestamp"
stampReadme.usage = "lute run stamp-readme [--version vX.Y.Z]"

stampReadme.arguments = {
	{
		name = "version",
		kind = "option",
		options = {
			help = "Upstream StyLua tag that was just checked",
			aliases = { "v" },
			required = false,
		},
	},
}

export type Options = {
	version: string?,
}

local START = "<!-- LAST_CHECKED:START -->"
local CLOSE = "<!-- LAST_CHECKED:END -->"

function stampReadme.run(options_: Options?)
	local options: Options = options_ or {}

	local handle = fs.open("README.md", "r")
	local text = fs.read(handle)
	fs.close(handle)

	local startIdx = string.find(text, START, 1, true)
	local endIdx = string.find(text, CLOSE, 1, true)
	if startIdx == nil or endIdx == nil then
		print("stamp-readme: README.md is missing LAST_CHECKED markers")
		process.exit(1)
		return
	end

	local stamp = os.date("!%Y-%m-%d %H:%M UTC") :: string
	if options.version ~= nil and options.version ~= "" then
		stamp = `{stamp} (StyLua {options.version})`
	end

	local block = `{START}\n_Last checked against upstream: {stamp}_\n{CLOSE}`
	local before = string.sub(text, 1, startIdx - 1)
	local after = string.sub(text, endIdx + #CLOSE)

	handle = fs.open("README.md", "w")
	fs.write(handle, `{before}{block}{after}`)
	fs.close(handle)
end

return stampReadme
