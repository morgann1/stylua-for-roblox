local process = require("@lute/process")

local cli = require("./lib/cli/parser")
local command = require("./commands/bump-stylua-version")

local function main()
	local parser = cli.parser()
	parser:setDescription(command.description)
	parser:setCommandName(`lute run {command.name}`)

	for _, arg: any in command.arguments do
		parser:add(arg.name, arg.kind, arg.options)
	end

	parser:parse(process.args)

	command.run({
		from = parser:get("from") :: string?,
		to = parser:get("to") :: string?,
	})
end

main()
