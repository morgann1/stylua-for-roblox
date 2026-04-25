--!strict

local fs = require("@lute/fs")
local process = require("@lute/process")

local bumpStyluaVersion = {}

bumpStyluaVersion.name = "bump-stylua-version"
bumpStyluaVersion.description = "Bumps plugin version + CHANGELOG in response to a StyLua upstream bump"
bumpStyluaVersion.usage = "lute run bump-stylua-version --from vA.B.C --to vX.Y.Z"

bumpStyluaVersion.arguments = {
	{
		name = "from",
		kind = "option",
		options = {
			help = "Previous StyLua tag (the version we're moving away from)",
			required = true,
		},
	},
	{
		name = "to",
		kind = "option",
		options = {
			help = "New StyLua tag (the version we're moving to)",
			required = true,
		},
	},
}

export type Options = {
	from: string?,
	to: string?,
}

type Bump = "major" | "minor" | "patch"

local WALLY_PATH = "plugin/wally.toml"
local CHANGELOG_PATH = "CHANGELOG.md"

local function readFile(path: string): string
	local handle = fs.open(path, "r")
	local contents = fs.read(handle)
	fs.close(handle)
	return contents
end

local function writeFile(path: string, contents: string)
	local handle = fs.open(path, "w")
	fs.write(handle, contents)
	fs.close(handle)
end

local function parseSemver(raw: string): (number?, number?, number?)
	local stripped = string.match(raw, "^v(.+)$") or raw
	local major, minor, patch = string.match(stripped, "^(%d+)%.(%d+)%.(%d+)")
	if major == nil then
		return nil, nil, nil
	end
	return tonumber(major), tonumber(minor), tonumber(patch)
end

local function classify(
	fromMajor: number,
	fromMinor: number,
	_fromPatch: number,
	toMajor: number,
	toMinor: number,
	_toPatch: number
): Bump
	if fromMajor ~= toMajor then
		return "major"
	end
	if fromMinor ~= toMinor then
		return "minor"
	end
	return "patch"
end

local function applyBump(major: number, minor: number, patch: number, kind: Bump): (number, number, number)
	if major == 0 then
		if kind == "major" or kind == "minor" then
			return 0, minor + 1, 0
		end
		return 0, minor, patch + 1
	end
	if kind == "major" then
		return major + 1, 0, 0
	end
	if kind == "minor" then
		return major, minor + 1, 0
	end
	return major, minor, patch + 1
end

local function bumpWally(newVersion: string)
	local contents = readFile(WALLY_PATH)
	local replaced, count = string.gsub(contents, '(version%s*=%s*")[^"]+(")', `%1{newVersion}%2`, 1)
	if count == 0 then
		print(`bump-stylua-version: could not find version field in {WALLY_PATH}`)
		process.exit(1)
		return
	end
	writeFile(WALLY_PATH, replaced)
end

local function bumpChangelog(newVersion: string, newStyluaTag: string)
	local contents = readFile(CHANGELOG_PATH)
	local marker = "## [Unreleased]"
	local startIdx = string.find(contents, marker, 1, true)
	if startIdx == nil then
		print(`bump-stylua-version: could not find [Unreleased] section in {CHANGELOG_PATH}`)
		process.exit(1)
		return
	end

	local afterUnreleased = startIdx + #marker
	local nextSection = string.find(contents, "\n## %[", afterUnreleased)
	local insertAt = if nextSection ~= nil then nextSection + 1 else #contents + 1

	local today = os.date("!%Y-%m-%d") :: string
	local section = `## [{newVersion}] - {today}\n\n### 🔄 Updates\n- StyLua updated to {newStyluaTag}.\n\n`

	local before = string.sub(contents, 1, insertAt - 1)
	local after = string.sub(contents, insertAt)
	writeFile(CHANGELOG_PATH, `{before}{section}{after}`)
end

function bumpStyluaVersion.run(options_: Options?)
	local options: Options = options_ or {}
	if options.from == nil or options.to == nil then
		print("bump-stylua-version: --from and --to are required")
		process.exit(1)
		return
	end

	local fromMajor, fromMinor, fromPatch = parseSemver(options.from :: string)
	local toMajor, toMinor, toPatch = parseSemver(options.to :: string)
	if fromMajor == nil or toMajor == nil then
		print(`bump-stylua-version: could not parse semver from --from={options.from} --to={options.to}`)
		process.exit(1)
		return
	end

	local kind: Bump = classify(
		fromMajor :: number,
		fromMinor :: number,
		fromPatch :: number,
		toMajor :: number,
		toMinor :: number,
		toPatch :: number
	)

	local wally = readFile(WALLY_PATH)
	local current = string.match(wally, 'version%s*=%s*"([^"]+)"')
	if current == nil then
		print(`bump-stylua-version: could not parse version from {WALLY_PATH}`)
		process.exit(1)
		return
	end
	local curMajor, curMinor, curPatch = parseSemver(current :: string)
	if curMajor == nil then
		print(`bump-stylua-version: could not parse plugin version "{current}"`)
		process.exit(1)
		return
	end

	local newMajor, newMinor, newPatch = applyBump(curMajor :: number, curMinor :: number, curPatch :: number, kind)
	local newVersion = `{newMajor}.{newMinor}.{newPatch}`

	bumpWally(newVersion)
	bumpChangelog(newVersion, options.to :: string)

	print(newVersion)
end

return bumpStyluaVersion
