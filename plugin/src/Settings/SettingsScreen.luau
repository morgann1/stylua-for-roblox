--!strict

local StyluaForRoblox = script:FindFirstAncestor("StyluaForRoblox")

local Foundation = require(StyluaForRoblox.Packages.Foundation)
local React = require(StyluaForRoblox.Packages.React)
local Settings = require(StyluaForRoblox.Source.Settings)

local e = React.createElement

local SCREEN_PADDING = UDim.new(0, 12)
local ROW_GAP = UDim.new(0, 6)
local TEXT_GAP = UDim.new(0, 2)
local CONTROL_GAP = UDim.new(0, 8)
local CONTROL_WIDTH = 140

type EnumOption = { id: string, text: string }

local SYNTAX_OPTIONS: { EnumOption } = {
	{ id = "Luau", text = "Luau" },
	{ id = "Lua54", text = "Lua 5.4" },
	{ id = "Lua53", text = "Lua 5.3" },
	{ id = "Lua52", text = "Lua 5.2" },
	{ id = "Lua51", text = "Lua 5.1" },
	{ id = "LuaJIT", text = "LuaJIT" },
	{ id = "CfxLua", text = "Cfx Lua" },
	{ id = "All", text = "All (mixed)" },
}

local INDENT_TYPE_OPTIONS: { EnumOption } = {
	{ id = "Tabs", text = "Tabs" },
	{ id = "Spaces", text = "Spaces" },
}

local LINE_ENDINGS_OPTIONS: { EnumOption } = {
	{ id = "Unix", text = "Unix (LF)" },
	{ id = "Windows", text = "Windows (CRLF)" },
}

local QUOTE_STYLE_OPTIONS: { EnumOption } = {
	{ id = "AutoPreferDouble", text = "Auto, prefer double" },
	{ id = "AutoPreferSingle", text = "Auto, prefer single" },
	{ id = "ForceDouble", text = "Always double" },
	{ id = "ForceSingle", text = "Always single" },
}

local CALL_PAREN_OPTIONS: { EnumOption } = {
	{ id = "Always", text = "Always" },
	{ id = "NoSingleString", text = "Omit for single string" },
	{ id = "NoSingleTable", text = "Omit for single table" },
	{ id = "None", text = "Omit for single string or table" },
	{ id = "Input", text = "Match input" },
}

local COLLAPSE_OPTIONS: { EnumOption } = {
	{ id = "Never", text = "Never" },
	{ id = "FunctionOnly", text = "Functions only" },
	{ id = "ConditionalOnly", text = "Conditionals only" },
	{ id = "Always", text = "Always" },
}

local BLOCK_NEWLINE_OPTIONS: { EnumOption } = {
	{ id = "Never", text = "Never" },
	{ id = "Preserve", text = "Preserve from input" },
}

local SPACE_AFTER_FN_OPTIONS: { EnumOption } = {
	{ id = "Never", text = "Never" },
	{ id = "Definitions", text = "Definitions only" },
	{ id = "Calls", text = "Calls only" },
	{ id = "Always", text = "Always" },
}

local function Dropdown<T>(props: {
	value: T,
	options: { EnumOption },
	onChanged: (T) -> (),
})
	return e(Foundation.Dropdown.Root, {
		label = "",
		value = (props.value :: any) :: string,
		items = props.options,
		width = UDim.new(0, CONTROL_WIDTH),
		onItemChanged = function(id: any)
			props.onChanged(id :: T)
		end,
	})
end

local function SettingRow(props: {
	name: string,
	description: string,
	layoutOrder: number,
	control: any,
})
	return e(Foundation.View, {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.layoutOrder,
		layout = {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
	}, {
		Body = e(Foundation.View, {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 0,
			layout = {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				Padding = CONTROL_GAP,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			},
		}, {
			Text = e(Foundation.View, {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 0,
				flexItem = {
					FlexMode = Enum.UIFlexMode.Shrink,
				},
				layout = {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = TEXT_GAP,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
			}, {
				Name = e(Foundation.Text, {
					Text = props.name,
					tag = "text-title-small text-align-x-left",
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 0,
				}),
				Hint = e(Foundation.Text, {
					Text = props.description,
					tag = "text-body-small text-align-x-left text-wrap",
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 1,
				}),
			}),
			Control = e(Foundation.View, {
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 1,
			}, {
				Inner = props.control,
			}),
		}),
		Divider = e(Foundation.Divider, {
			LayoutOrder = 1,
		}),
	})
end

local function SettingsScreen()
	local settings = Settings.useSettings()

	return e(Foundation.ScrollView, {
		Size = UDim2.fromScale(1, 1),
		padding = SCREEN_PADDING,
		scroll = {
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			VerticalScrollBarInset = Enum.ScrollBarInset.None,
			scrollBarVisibility = "None",
		},
		layout = {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = ROW_GAP,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
	}, {
		Header = e(Foundation.Text, {
			Text = "StyLua Settings",
			tag = "text-title-large text-align-x-left",
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 0,
		}),

		Syntax = e(SettingRow, {
			name = "Syntax",
			description = "Lua dialect to format. Use Luau for Roblox scripts.",
			layoutOrder = 1,
			control = e(Dropdown, {
				value = settings.syntax,
				options = SYNTAX_OPTIONS,
				onChanged = function(value: Settings.LuaVersion)
					Settings.update({ syntax = value })
				end,
			}),
		}),

		ColumnWidth = e(SettingRow, {
			name = "Column width",
			description = "Maximum target line length before StyLua wraps.",
			layoutOrder = 2,
			control = e(Foundation.NumberInput, {
				label = "",
				value = settings.columnWidth,
				minimum = 20,
				maximum = 240,
				step = 1,
				precision = 0,
				size = "Medium",
				width = UDim.new(0, CONTROL_WIDTH),
				onChanged = function(value: number)
					Settings.update({ columnWidth = value })
				end,
			}),
		}),

		LineEndings = e(SettingRow, {
			name = "Line endings",
			description = "Newline characters to write in formatted output.",
			layoutOrder = 3,
			control = e(Dropdown, {
				value = settings.lineEndings,
				options = LINE_ENDINGS_OPTIONS,
				onChanged = function(value: Settings.LineEndings)
					Settings.update({ lineEndings = value })
				end,
			}),
		}),

		IndentType = e(SettingRow, {
			name = "Indent type",
			description = "Whether to indent with tabs or spaces.",
			layoutOrder = 4,
			control = e(Dropdown, {
				value = settings.indentType,
				options = INDENT_TYPE_OPTIONS,
				onChanged = function(value: Settings.IndentType)
					Settings.update({ indentType = value })
				end,
			}),
		}),

		IndentWidth = e(SettingRow, {
			name = "Indent width",
			description = "Number of spaces (or tab columns) per indent level.",
			layoutOrder = 5,
			control = e(Foundation.NumberInput, {
				label = "",
				value = settings.indentWidth,
				minimum = 1,
				maximum = 16,
				step = 1,
				precision = 0,
				size = "Medium",
				width = UDim.new(0, CONTROL_WIDTH),
				onChanged = function(value: number)
					Settings.update({ indentWidth = value })
				end,
			}),
		}),

		QuoteStyle = e(SettingRow, {
			name = "Quote style",
			description = "Whether to prefer single or double quotes for strings.",
			layoutOrder = 6,
			control = e(Dropdown, {
				value = settings.quoteStyle,
				options = QUOTE_STYLE_OPTIONS,
				onChanged = function(value: Settings.QuoteStyle)
					Settings.update({ quoteStyle = value })
				end,
			}),
		}),

		CallParentheses = e(SettingRow, {
			name = "Call parentheses",
			description = "Whether to keep parentheses on calls with a single string or table argument.",
			layoutOrder = 7,
			control = e(Dropdown, {
				value = settings.callParentheses,
				options = CALL_PAREN_OPTIONS,
				onChanged = function(value: Settings.CallParenType)
					Settings.update({ callParentheses = value })
				end,
			}),
		}),

		SpaceAfterFn = e(SettingRow, {
			name = "Space after function names",
			description = "Whether to insert a space between a function name and its argument list.",
			layoutOrder = 8,
			control = e(Dropdown, {
				value = settings.spaceAfterFunctionNames,
				options = SPACE_AFTER_FN_OPTIONS,
				onChanged = function(value: Settings.SpaceAfterFunctionNames)
					Settings.update({ spaceAfterFunctionNames = value })
				end,
			}),
		}),

		Collapse = e(SettingRow, {
			name = "Collapse simple statements",
			description = "Collapse single-line if/while/for/function bodies onto one line when possible.",
			layoutOrder = 9,
			control = e(Dropdown, {
				value = settings.collapseSimpleStatement,
				options = COLLAPSE_OPTIONS,
				onChanged = function(value: Settings.CollapseSimpleStatement)
					Settings.update({ collapseSimpleStatement = value })
				end,
			}),
		}),

		BlockGaps = e(SettingRow, {
			name = "Block newline gaps",
			description = "Whether to preserve blank lines from input inside blocks.",
			layoutOrder = 10,
			control = e(Dropdown, {
				value = settings.blockNewlineGaps,
				options = BLOCK_NEWLINE_OPTIONS,
				onChanged = function(value: Settings.BlockNewlineGaps)
					Settings.update({ blockNewlineGaps = value })
				end,
			}),
		}),

		SortRequires = e(SettingRow, {
			name = "Sort requires",
			description = "Group and alphabetize require statements at the top of each file.",
			layoutOrder = 11,
			control = e(Foundation.Toggle, {
				label = "",
				isChecked = settings.sortRequires.enabled,
				onActivated = function(value: boolean)
					Settings.update({ sortRequires = { enabled = value } })
				end,
			}),
		}),

		Reset = e(Foundation.Button, {
			text = "Reset to defaults",
			LayoutOrder = 12,
			onActivated = function()
				Settings.reset()
			end,
		}),
	})
end

return SettingsScreen
