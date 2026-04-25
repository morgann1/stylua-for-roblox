--!strict

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local wasmFactory = require(StyluaForRoblox.Wasm.StyLua)

local function noOp(...: any)
	local _ = ...
end
local function returnZero(): number
	return 0
end

local instance: any = nil

local function getInstance(): any
	if instance ~= nil then
		return instance
	end

	local panicImpl: (number, number) -> () = function(_ptr: number, _len: number)
		error("[StyLua] wasm panic during init")
	end

	local imports = {
		__wbindgen_placeholder__ = {
			func_list = {
				__wbindgen_describe = noOp,
				__wbindgen_describe_cast = noOp,
				["__wbg___wbindgen_throw_be289d5034ed271b"] = function(ptr: number, len: number)
					panicImpl(ptr, len)
				end,
			},
			memory_list = {},
			global_list = {},
			table_list = {},
		},
		__wbindgen_externref_xform__ = {
			func_list = {
				__wbindgen_externref_table_set_null = noOp,
				__wbindgen_externref_table_grow = returnZero,
			},
			memory_list = {},
			global_list = {},
			table_list = {},
		},
	}

	instance = wasmFactory(imports)

	panicImpl = function(ptr: number, len: number)
		local msg = instance.rt.load.string(instance.memory_list.memory, ptr, len)
		error(`[StyLua] wasm panic: {msg}`)
	end

	return instance
end

local function memory(): any
	return getInstance().memory_list.memory
end

local function funcs(): any
	return getInstance().func_list
end

local function malloc(size: number, align: number?): number
	return funcs().__wbindgen_malloc(size, align or 1)
end

local function free(ptr: number, size: number, align: number?)
	funcs().__wbindgen_free(ptr, size, align or 1)
end

local function writeString(value: string): (number, number)
	local len = #value
	if len == 0 then
		return 0, 0
	end
	local ptr = malloc(len, 1)
	getInstance().rt.store.string(memory(), ptr, value, len)
	return ptr, len
end

local function readString(ptr: number, len: number): string
	if len == 0 then
		return ""
	end
	return getInstance().rt.load.string(memory(), ptr, len)
end

local function readU32(ptr: number): number
	return getInstance().rt.load.i32(memory(), ptr)
end

export type IndentType = "Tabs" | "Spaces"
export type LineEndings = "Unix" | "Windows"
export type QuoteStyle = "AutoPreferDouble" | "AutoPreferSingle" | "ForceDouble" | "ForceSingle"
export type CallParentheses = "Always" | "NoSingleString" | "NoSingleTable" | "None" | "Input"
export type LuaVersion = "Lua51" | "Lua52" | "Lua53" | "Lua54" | "LuaJIT" | "Luau" | "CfxLua"
export type CollapseSimpleStatement = "Never" | "FunctionOnly" | "ConditionalOnly" | "Always"

export type Config = {
	columnWidth: number?,
	indentWidth: number?,
	indentType: IndentType?,
	lineEndings: LineEndings?,
	quoteStyle: QuoteStyle?,
	callParentheses: CallParentheses?,
	collapseSimpleStatement: CollapseSimpleStatement?,
	spaceAfterFunctionNames: number?,
	sortRequires: boolean?,
	blockNewlineGaps: boolean?,
	syntax: LuaVersion?,
}

local INDENT_TYPE: { [IndentType]: number } = { Tabs = 0, Spaces = 1 }
local LINE_ENDINGS: { [LineEndings]: number } = { Unix = 0, Windows = 1 }
local QUOTE_STYLE: { [QuoteStyle]: number } = {
	AutoPreferDouble = 0,
	AutoPreferSingle = 1,
	ForceDouble = 2,
	ForceSingle = 3,
}
local CALL_PARENTHESES: { [CallParentheses]: number } = {
	Always = 0,
	NoSingleString = 1,
	NoSingleTable = 2,
	None = 3,
	Input = 4,
}
local COLLAPSE_SIMPLE_STATEMENT: { [CollapseSimpleStatement]: number } = {
	Never = 0,
	FunctionOnly = 1,
	ConditionalOnly = 2,
	Always = 3,
}
local LUA_VERSION: { [LuaVersion]: number } = {
	Lua51 = 0,
	Lua52 = 1,
	Lua53 = 2,
	Lua54 = 3,
	LuaJIT = 4,
	Luau = 5,
	CfxLua = 6,
}

local function newConfig(options: Config?): number
	local f = funcs()
	local handle = f.config_new()
	if options == nil then
		return handle
	end

	if options.columnWidth ~= nil then
		f.__wbg_set_config_column_width(handle, options.columnWidth)
	end
	if options.indentWidth ~= nil then
		f.__wbg_set_config_indent_width(handle, options.indentWidth)
	end
	if options.indentType ~= nil then
		f.__wbg_set_config_indent_type(handle, INDENT_TYPE[options.indentType])
	end
	if options.lineEndings ~= nil then
		f.__wbg_set_config_line_endings(handle, LINE_ENDINGS[options.lineEndings])
	end
	if options.quoteStyle ~= nil then
		f.__wbg_set_config_quote_style(handle, QUOTE_STYLE[options.quoteStyle])
	end
	if options.callParentheses ~= nil then
		f.__wbg_set_config_call_parentheses(handle, CALL_PARENTHESES[options.callParentheses])
	end
	if options.collapseSimpleStatement ~= nil then
		f.__wbg_set_config_collapse_simple_statement(handle, COLLAPSE_SIMPLE_STATEMENT[options.collapseSimpleStatement])
	end
	if options.spaceAfterFunctionNames ~= nil then
		f.__wbg_set_config_space_after_function_names(handle, options.spaceAfterFunctionNames)
	end
	if options.sortRequires ~= nil then
		f.__wbg_set_config_sort_requires(handle, if options.sortRequires then 1 else 0)
	end
	if options.blockNewlineGaps ~= nil then
		f.__wbg_set_config_block_newline_gaps(handle, if options.blockNewlineGaps then 1 else 0)
	end
	if options.syntax ~= nil then
		f.__wbg_set_config_syntax(handle, LUA_VERSION[options.syntax])
	end

	return handle
end

local function freeConfig(handle: number)
	funcs().__wbg_config_free(handle)
end

local function format(source: string, options: (Config | number)?): string
	local f = funcs()
	local mem = memory()
	local rt = getInstance().rt

	local configHandle: number
	local ownsConfig: boolean
	if typeof(options) == "number" then
		configHandle = options
		ownsConfig = false
	else
		configHandle = newConfig(options)
		ownsConfig = true
	end

	local retptr = malloc(16, 4)
	rt.store.i32(mem, retptr, 0)
	rt.store.i32(mem, retptr + 4, 0)
	rt.store.i32(mem, retptr + 8, 0)

	local codePtr, codeLen = writeString(source)

	f.formatCode(retptr, codePtr, codeLen, configHandle, 0, 0)

	local dataPtr = readU32(retptr)
	local dataLen = readU32(retptr + 4)
	local isErr = readU32(retptr + 8)
	local data = readString(dataPtr, dataLen)

	if dataPtr ~= 0 and dataLen ~= 0 then
		free(dataPtr, dataLen, 1)
	end
	free(retptr, 16, 4)
	if ownsConfig then
		freeConfig(configHandle)
	end

	if isErr ~= 0 then
		error(`[StyLua] format error: {data}`)
	end

	return data
end

return {
	format = format,
	newConfig = newConfig,
	freeConfig = freeConfig,
}
