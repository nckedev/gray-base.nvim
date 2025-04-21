require("gray-base.hsl")

-- vim.highlight.priorities.semantic_tokens = 95

vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") then
	vim.cmd.syntax("reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "gray-base"

local function is_dark()
	if vim.o.background == "dark" then
		return true
	else
		return false
	end
end

---Clamps a value between 0 and max
---@param x integer
---@param max integer
---@return integer
local function clamp(x, max)
	if x > max then
		return max
	elseif x < 0 then
		return 0
	else
		return x
	end
end

---@param h integer hue
---@param s integer sat
---@param l integer lum
---@return string hex the hsl converted to hex
local function hsl(h, s, l)
	h = clamp(h, 360) / 360
	s = clamp(s, 100) / 100
	l = clamp(l, 100) / 100

	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		local function hue2rgb(p, q, t)
			if t < 0 then
				t = t + 1
			end
			if t > 1 then
				t = t - 1
			end
			if t < 1 / 6 then
				return p + (q - p) * 6 * t
			end
			if t < 1 / 2 then
				return q
			end
			if t < 2 / 3 then
				return p + (q - p) * (2 / 3 - t) * 6
			end
			return p
		end

		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue2rgb(p, q, h + 1 / 3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1 / 3)
	end

	local res = "#"
		.. string.format("%02x", r * 255)
		.. string.format("%02x", g * 255)
		.. string.format("%02x", b * 255)
	return res
end

---Generate a gray (hexstring) value with a tint
---if the the bg is set to "light" the gray values will be inverted
---@param h integer
---@param s integer
---@param x integer
---@return string
local function gray(h, s, x)
	--if lightmode, invert the gray colors
	if is_dark() == false then
		x = 100 - x
	end

	return hsl(h, s, x)
end

---Generate variants from a color
---@param color HslColor
---@param opts Options
---@return HslColorWithVariance
local function generate_variants(color, opts)
	local h = color.hue
	local s = color.saturation
	local l = color.lightness

	if opts.inverted_lightness == true and is_dark() == false then
		l = 100 - l
	end
	return {
		monochrome = hsl(h, 0, l),
		default = hsl(h, s, l),
		dark = hsl(h, s, l - opts.lightness_variance),
		light = hsl(h, s, l + opts.lightness_variance),
		strong = hsl(h, 100, 50),
	}
end

---Rounds a number to a integer
---@param x number
---@return integer
local function round(x)
	if x >= 0.5 then
		return math.ceil(x)
	else
		return math.floor(x)
	end
end

local function generate_gray_scale(opts)
	-- 5 base grays and 5 highlight grays and 3 mid grays
	-- the step between base5 and mid1 should be twice the steps between each base step
	-- ex min = 10 max = 90
	-- base1
	assert(opts.grays.max > opts.grays.min, "max need to be bigger than min")

	-- 14 steps is need for 15 numbers
	local step = (opts.grays.max - opts.grays.min) / 14
	assert(step > 0, "not enough difference between min and max to make 15 different shades")

	local x = opts.grays.min
	local scale = {}
	for i = 1, 15 do
		scale[i] = round(x)
		x = x + step
	end

	local h = opts.tint.hue
	local s = opts.tint.saturation

	return {
		min = gray(h, s, 0),
		max = gray(h, s, 100),
		always_dark = hsl(h, s, opts.grays.min),
		always_light = hsl(h, s, opts.grays.max),

		bg1 = gray(h, s, scale[1]),
		bg2 = gray(h, s, scale[2]),
		bg3 = gray(h, s, scale[3]),
		bg4 = gray(h, s, scale[4]),
		bg5 = gray(h, s, scale[5]),
		bg6 = gray(h, s, scale[6]),
		bg7 = gray(h, s, scale[7]),

		mid = gray(h, s, scale[8]),

		fg7 = gray(h, s, scale[9]),
		fg6 = gray(h, s, scale[10]),
		fg5 = gray(h, s, scale[11]),
		fg4 = gray(h, s, scale[12]),
		fg3 = gray(h, s, scale[13]),
		fg2 = gray(h, s, scale[14]),
		fg1 = gray(h, s, scale[15]),
	}
end

---Creates an table from a hue value
---@param x integer
---@param opts Options
---@return table
local function hsl_obj_from_hue(x, opts)
	local lightness = opts.colors.lightness

	if opts.inverted_lightness == true and is_dark() == false then
		lightness = 100 - lightness
	end

	return {
		hue = x,
		saturation = opts.colors.saturation,
		lightness = lightness,
	}
end

---Generate colors
---@param opts Options
---@return table
local function generate_colors(opts)
	local colors = {
		red = hsl_obj_from_hue(0, opts),
		orange = hsl_obj_from_hue(42, opts),
		yellow = hsl_obj_from_hue(50, opts),
		green = hsl_obj_from_hue(85, opts),
		blue = hsl_obj_from_hue(210, opts),
		purple = hsl_obj_from_hue(232, opts),
		red_pure = hsl_obj_from_hue(0, opts),
		orange_pure = hsl_obj_from_hue(30, opts),
		yellow_pure = hsl_obj_from_hue(60, opts),
		green_pure = hsl_obj_from_hue(120, opts),
		blue_pure = hsl_obj_from_hue(240, opts),
	}

	local grays = generate_gray_scale(opts)

	return {

		grays = grays,

		primary = generate_variants(opts.colors.primary, opts),
		secondary = generate_variants(opts.colors.secondary, opts),
		accent = generate_variants(opts.colors.accent, opts),
		strings = generate_variants(opts.colors.strings, opts),
		cursor = generate_variants(opts.colors.cursor, opts),
		purple = generate_variants(colors.purple, opts),
		red = generate_variants(colors.red, opts),
		green = generate_variants(colors.green, opts),
		orange = generate_variants(colors.orange, opts),
		yellow = generate_variants(colors.yellow, opts),

		-- used as indicator of unused hlgroups or as a testing for finding hlgroups
		hl_error = hsl(0, 100, 50),
	}
end

---Generates a palette
---@param opts Options
---@return table
local function generate_palette(opts)
	local colors = generate_colors(opts)

	return {
		bg1 = colors.grays.bg1,
		bg2 = colors.grays.bg2,
		bg3 = colors.grays.bg3,
		bg4 = colors.grays.bg4,
		bg5 = colors.grays.bg5,
		bg6 = colors.grays.bg6,
		bg7 = colors.grays.bg7,

		mid = colors.grays.mid,

		fg7 = colors.grays.fg7,
		fg6 = colors.grays.fg6,
		fg5 = colors.grays.fg5,
		fg4 = colors.grays.fg4,
		fg3 = colors.grays.fg3,
		fg2 = colors.grays.fg2,
		fg1 = colors.grays.fg1,

		accent = colors.accent.default,
		accent_light = colors.primary.light,

		fn = colors.primary.default,
		keyword = colors.primary.default,

		dark = colors.grays.always_dark,
		light = colors.grays.always_light,

		cursor_line = colors.grays.bg2,
		comment = colors.grays.bg4,
		doc_comment = colors.grays.bg5,
		oob = colors.grays.min,
		cursor = colors.cursor.default,

		visual = colors.grays.bg3,
		literal = colors.strings.default,
		number = colors.secondary.default,

		add = colors.green.default,
		change = colors.yellow.default,
		delete = colors.red.default,

		error = colors.red.default,
		warn = colors.yellow.default,
		hint = colors.grays.fg4,
		info = colors.grays.fg4,
		ok = colors.grays.norm1,
	}
end

---Generates hl groups
---@param opts Options
---@return table
local function generate_hlgroups(opts)
	local palette = generate_palette(opts)
	return {
		-- normal {{{
		Normal = { fg = palette.fg3, bg = palette.bg1 },
		NormalFloat = { fg = palette.fg3, bg = palette.bg3 },
		NormalBorder = { link = "NormalFloat" },

		Comment = { fg = palette.comment, italic = true },
		SpecialComment = { link = "Comment" },
		Critical = { fg = palette.fg1, bg = palette.accent, bold = true },
		--}}}
		-- constant literals {{{
		Number = { fg = palette.number, bold = false },
		String = { fg = palette.literal, bold = false },
		Constant = { link = "Number" },
		Character = { link = "String" },
		Boolean = { link = "Number" },
		Float = { link = "Number" },
		Directory = { link = "String" },
		Title = { link = "String" },
		--}}}
		-- syntax {{{
		Function = { fg = palette.fn, bold = false },
		Identifier = { fg = palette.fg5 },

		Statement = { fg = palette.fg3, bold = false },
		Conditonal = { link = "Statement" },
		Repeat = { link = "Statement" },
		Label = { link = "Statement" },
		Keyword = { link = "Statement" },
		Exception = { link = "Statement" },

		PreProc = { bold = true },
		Include = { link = "PreProc" },
		Define = { link = "PreProc" },
		Macro = { link = "PreProc" },
		PreCondit = { link = "PreProc" },

		Type = { fg = palette.fg2, underline = false },
		StorageClass = { link = "Type" },
		Structure = { link = "Type" },
		Typedef = { link = "Type" },

		Operator = { fg = palette.mid },
		Debug = { link = "Operator" },

		Special = { fg = palette.fg5, italic = true },
		SpecialChar = { link = "Special" },
		Tag = { link = "Special" },
		Delimiter = { link = "Special" },

		Underlined = { underline = true },
		Ignore = { fg = palette.fg5 },
		Error = { reverse = true, bold = true },
		Todo = { fg = palette.accent, italic = true },
		--}}}
		-- spell {{{
		SpellBad = { undercurl = true, sp = palette.fg5 },
		SpellCap = { link = "SpellBad" },
		SpellLocal = { link = "SpellBad" },
		SpellRare = { link = "SpellBad" },
		--}}}
		-- ui {{{
		ColorColumn = { link = "CursorLine" },
		Conceal = { link = "Comment" },
		CurSearch = { bg = palette.accent, fg = palette.dark },
		Cursor = { fg = palette.dark, bg = palette.cursor },
		CursorColumn = { link = "CursorLine" },
		CursorLine = { bg = palette.cursor_line },
		CursorLineNr = { fg = palette.bg4, bg = palette.cursor_line, bold = false },
		EndOfBuffer = { link = "Normal" },
		ErrorMsg = { fg = palette.accent, bold = true },
		FloatBorder = { fg = palette.bg3, bg = palette.bg3 },
		FloatTitle = {
			fg = palette.mid,
			bg = palette.bg3,
			bold = true,
			underline = true,
		},
		FoldColumn = { link = "SignColumn" },
		Folded = { fg = palette.bg5, bg = palette.bg3, bold = true },
		IncSearch = { link = "CurSearch" },
		LineNr = { fg = palette.comment },
		MatchParen = { fg = palette.fg5, bold = true },
		ModeMsg = { fg = palette.norm1, bold = true },
		MoreMsg = { fg = palette.norm1, bold = true },
		MsgArea = { fg = palette.norm1, bg = palette.base1 },
		NonText = { fg = palette.mid },
		NormalNC = { link = "Normal" },
		NvimInternalError = { link = "ErrorMsg" },
		Pmenu = { bg = palette.bg3 },
		PmenuSbar = { bg = palette.bg3, reverse = true },
		PmenuKind = { bg = palette.bg3 },

		PmenuSel = { fg = palette.fg3, bg = palette.bg3, reverse = true, bold = false },
		PmenuKindSel = { fg = palette.literal, bg = palette.bg3, reverse = true, bold = true },
		Question = { bold = true },
		QuickFixLine = { link = "Visual" },
		Search = { bg = palette.visual },
		SignColumn = { bg = palette.bg, fg = palette.norm1, bold = true },
		SpecialKey = { fg = palette.norm_subtle },
		StatusLine = { fg = palette.fg3, bg = palette.cursor_line },
		StatusLineNC = { fg = palette.norm1, bg = palette.oob, italic = true },
		StatusLineTerm = { link = "StatusLine" },
		StatusLineTermNC = { link = "StatusLineNC" },
		Substitute = { link = "IncSearch" },
		TabLine = { fg = palette.norm3, bg = palette.base3 },
		TabLineFill = { bg = palette.oob },
		TabLineSel = { fg = palette.norm1, bg = palette.bg, bold = true },
		Visual = { bg = palette.visual, fg = palette.base1 },
		WarningMsg = { fg = palette.critical, bold = true },
		WildMenu = { link = "IncSearch" },
		WinBar = { link = "StatusLine" },
		WinBarNC = { link = "StatusLineNc" },
		WinSeparator = { fg = palette.norm, bg = palette.base1 },
		--}}}
		-- diagnostics {{{
		DiagnosticDeprecated = { strikethrough = true },
		DiagnosticError = { fg = palette.error, bold = false },
		DiagnosticWarn = { fg = palette.warn, bold = false },
		DiagnosticHint = { fg = palette.hint, bold = false },
		DiagnosticInfo = { fg = palette.info, bold = false },
		DiagnosticOk = { fg = palette.ok, bold = false },

		DiagnosticUnderlineError = { sp = palette.error, undercurl = true, bold = true },
		DiagnosticUnderlineWarn = { sp = palette.warn, undercurl = true, bold = true },
		DiagnosticUnderlineHint = { sp = palette.hint, undercurl = true, bold = true },
		DiagnosticUnderlineInfo = { sp = palette.info, undercurl = true, bold = true },
		DiagnosticUnderlineOk = { sp = palette.norm, undercurl = true, bold = true },

		DiagnosticVirtualTextError = { link = "DiagnosticError" },
		DiagnosticVirtualTextHint = { link = "DiagnosticHint" },
		DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },
		DiagnosticVirtualTextWarn = { link = "DiagnosticWarn" },

		DiagnosticDefaultError = { link = "DiagnosticError" },
		DiagnosticDefaultHint = { link = "DiagnosticHint" },
		DiagnosticDefaultInfo = { link = "DiagnosticInfo" },
		DiagnosticDefaultWarn = { link = "DiagnosticWarn" },

		DiagnosticFloatingError = { link = "DiagnosticError" },
		DiagnosticFloatingHint = { link = "DiagnosticHint" },
		DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
		DiagnosticFloatingWarn = { link = "DiagnosticWarn" },

		DiagnosticSignError = { link = "DiagnosticError" },
		DiagnosticSignHint = { link = "DiagnosticHint" },
		DiagnosticSignInfo = { link = "DiagnosticInfo" },
		DiagnosticSignWarn = { link = "DiagnosticWarn" },
		--}}}
		-- git-related {{{
		Added = { fg = palette.bg1, bg = palette.add },
		Changed = { fg = palette.bg1, bg = palette.change },
		Removed = { fg = palette.bg1, bg = palette.delete },
		Deleted = { fg = palette.bg1, bg = palette.delete },

		DiffAdd = { link = "Added" },
		DiffChange = { link = "Changed" },
		DiffDelete = { link = "Removed" },
		DiffRemoved = { link = "Removed" },

		DiffAddGutter = { link = "Added" },
		DiffChangeGutter = { link = "Changed" },
		DiffDeleteGutter = { link = "Removed" },

		GitAdd = { link = "Added" },
		GitChange = { link = "Changed" },
		GitDelete = { link = "Removed" },
		--}}}
		-- quickscope.vim {{{
		QuickScopeCursor = { link = "Cursor" },
		QuickScopePrimary = { link = "Search" },
		QuickScopeSecondary = { link = "IncSearch" },
		--}}}
		-- mini.nvim {{{
		MiniStarterFooter = { link = "Normal" },
		MiniStarterHeader = { link = "Normal" },
		MiniStarterSection = { link = "Normal" },
		--}}}
		-- gitsigns.nvim{{{
		GitSignsAdd = { fg = palette.add },
		GitSignsChange = { fg = palette.change },
		GitSignsDelete = { fg = palette.delete },
		GitSignsAddNr = { fg = palette.add },
		GitSignsChangeNr = { fg = palette.change },
		GitSignsDeleteNr = { fg = palette.delete },
		GitSignsAddLn = { link = "Added" },
		GitSignsChangeLn = { link = "Changed" },
		GitSignsDeleteLn = { link = "Removed" },
		--}}}
		-- telescope.nvim {{{
		TelescopeSelection = { bg = palette.bg3 },
		TelescopeMatching = { fg = palette.accent },
		TelescopePromptNormal = { fg = palette.normal, bg = palette.bg3 },
		TelescopePromptBorder = { fg = palette.normal, bg = palette.bg3 },
		TelescopeResultsNormal = { bg = palette.bg2 },
		TelescopeResultsBorder = { bg = palette.bg2 },
		TelescopeResultsTitle = { bg = palette.bg2, fg = palette.bg2 },
		TelescopePromptTitle = { bg = palette.fn, fg = palette.dark },
		TelescopeSelectionCaret = { fg = palette.fn },
		--}}}
		--FzfLua
		FzfLuaFzfMatch = { fg = palette.error },
		FzfLuaSearch = { fg = palette.error },
		-- whichkey.nvim {{{
		WhichKey = { link = "NormalFloat" },
		WhichKeyDesc = { link = "WhichKey" },
		WhichKeyFloat = { link = "WhichKey" },
		WhichKeyGroup = { link = "Operator" },
		WhichKeyValue = { link = "Operator" },
		WhichKeyBorder = { link = "WhichKey" },
		WhichKeySeparator = { fg = palette.fn },
		--}}}
		-- oil.nvim {{{
		OilDir = { link = "Special" },
		OilCopy = { link = "Function" },
		OilMove = { link = "Function" },
		OilPurge = { link = "Function" },
		OilTrash = { link = "String" },
		OilChange = { link = "Change" },
		OilCreate = { link = "Add" },
		OilDelete = { link = "Removed" },
		OilSocket = { link = "String" },
		OilDirIcon = { link = "OilDir" },
		OilRestore = { link = "Function" },
		OilLinkTarget = { link = "Underline" },
		OilTrashSourcePath = { link = "Normal" },
		--}}}
		-- sidebar {{{
		NormalSB = { fg = palette.norm1, bg = palette.bg3 },
		SignColumnSB = { fg = palette.norm1, bg = palette.oob },
		WinSeparatorSB = { fg = palette.norm1, bg = palette.oob },
		--}}}

		-- tabs {{{
		Tabline = { fg = palette.fn, bg = palette.base2 },
		TablineSel = { fg = palette.norm1, bg = palette.base2 },
		TablineFill = { bg = palette.base1 },
		-- }}}

		-- TODO: testing
		-- NOTE: asd
		-- HACK: hack
		-- FIX: fix
		-- PERF: perf
		-- BUG: bug

		-- Todo comment
		TodoBgNOTE = { bg = palette.number, fg = palette.dark },
		TodoFgNOTE = { fg = palette.number },

		-- TODO  mer gul
		TodoBgTODO = { bg = palette.warn, fg = palette.dark },
		TodoFgTODO = { fg = palette.warn },

		-- ctrlf
		CtrlfHintChar = { link = "Removed" },
		CtrlfMatch = { link = "Changed" },
		CtrlfMatchClosest = { link = "Added" },
		CtrlfDarken = { link = "Comment" },
		CtrlfSearchbox = { fg = palette.dark, bg = palette.number },

		-- snacks
		SnacksPickerBorder = { bg = palette.bg2, fg = palette.bg2 },
		SnacksPicker = { bg = palette.bg1 },

		SnacksPickerInput = { bg = palette.bg2 },

		SnacksPickerMatch = { fg = palette.accent },
		SnacksPickerSelected = { fg = palette.accent },

		--treesitter stuff
		-- @variable                       various variable names
		-- @variable.builtin               built-in variable names (e.g. this, self)
		-- @variable.parameter             parameters of a function
		-- @variable.parameter.builtin     special parameters (e.g. _, it)
		-- @variable.member                object and struct fields
		-- @constant               constant identifiers
		-- @constant.builtin       built-in constant values
		-- @constant.macro         constants defined by the preprocessor
		-- @module                 modules or namespaces
		-- @module.builtin         built-in modules or namespaces
		-- @label                  GOTO and other labels (e.g. label: in C), including heredoc labels
		-- @string                 string literals
		-- @string.documentation   string documenting code (e.g. Python docstrings)
		-- @string.regexp          regular expressions
		-- @string.escape          escape sequences
		-- @string.special         other special strings (e.g. dates)
		-- @string.special.symbol  symbols or atoms
		-- @string.special.path    filenames
		-- @string.special.url     URIs (e.g. hyperlinks)
		-- @character              character literals
		-- @character.special      special characters (e.g. wildcards)
		-- @boolean                boolean literals
		-- @number                 numeric literals
		-- @number.float           floating-point number literals
		-- @type                   type or class definitions and annotations
		-- @type.builtin           built-in types
		-- @type.definition        identifiers in type definitions (e.g. typedef <type> <identifier> in C)
		-- @attribute              attribute annotations (e.g. Python decorators, Rust lifetimes)
		-- @attribute.builtin      builtin annotations (e.g. @property in Python)
		-- @property               the key in key/value pairs
		-- @function               function definitions
		-- @function.builtin       built-in functions
		-- @function.call          function calls
		-- @function.macro         preprocessor macros
		-- @function.method        method definitions
		-- @function.method.call   method calls
		-- @constructor            constructor calls and definitions
		-- @operator               symbolic operators (e.g. +, *)
		-- @keyword                keywords not fitting into specific categories
		-- @keyword.coroutine      keywords related to coroutines (e.g. go in Go, async/await in Python)
		-- @keyword.function       keywords that define a function (e.g. func in Go, def in Python)
		-- @keyword.operator       operators that are English words (e.g. and, or)
		-- @keyword.import         keywords for including or exporting modules (e.g. import, from in Python)
		-- @keyword.type           keywords describing namespaces and composite types (e.g. struct, enum)
		-- @keyword.modifier       keywords modifying other constructs (e.g. const, static, public)
		-- @keyword.repeat         keywords related to loops (e.g. for, while)
		-- @keyword.return         keywords like return and yield
		-- @keyword.debug          keywords related to debugging
		-- @keyword.exception      keywords related to exceptions (e.g. throw, catch)
		-- @keyword.conditional         keywords related to conditionals (e.g. if, else)
		-- @keyword.conditional.ternary ternary operator (e.g. ?, :)
		-- @keyword.directive           various preprocessor directives and shebangs
		-- @keyword.directive.define    preprocessor definition directives
		-- @punctuation.delimiter  delimiters (e.g. ;, ., ,)
		-- @punctuation.bracket    brackets (e.g. (), {}, [])
		-- @punctuation.special    special symbols (e.g. {} in string interpolation)
		-- @comment                line and block comments
		-- @comment.documentation  comments documenting code
		-- @comment.error          error-type comments (e.g. ERROR, FIXME, DEPRECATED)
		-- @comment.warning        warning-type comments (e.g. WARNING, FIX, HACK)
		-- @comment.todo           todo-type comments (e.g. TODO, WIP)
		-- @comment.note           note-type comments (e.g. NOTE, INFO, XXX)
		-- @markup.strong          bold text
		-- @markup.italic          italic text
		-- @markup.strikethrough   struck-through text
		-- @markup.underline       underlined text (only for literal underline markup!)
		-- @markup.heading         headings, titles (including markers)
		-- @markup.heading.1       top-level heading
		-- @markup.heading.2       section heading
		-- @markup.heading.3       subsection heading
		-- @markup.heading.4       and so on
		-- @markup.heading.5       and so forth
		-- @markup.heading.6       six levels ought to be enough for anybody
		-- @markup.quote           block quotes
		-- @markup.math            math environments (e.g. $ ... $ in LaTeX)
		-- @markup.link            text references, footnotes, citations, etc.
		-- @markup.link.label      link, reference descriptions
		-- @markup.link.url        URL-style links
		-- @markup.raw             literal or verbatim text (e.g. inline code)
		-- @markup.raw.block       literal or verbatim text as a stand-alone block
		-- @markup.list            list markers
		-- @markup.list.checked    checked todo-style list markers
		-- @markup.list.unchecked  unchecked todo-style list markers
		-- @diff.plus              added text (for diff files)
		-- @diff.minus             deleted text (for diff files)
		-- @diff.delta             changed text (for diff files)
		-- @tag                    XML-style tag names (e.g. in XML, HTML, etc.)
		-- @tag.builtin            builtin tag names (e.g. HTML5 tags)
		-- @tag.attribute          XML-style tag attributes
		-- @tag.delimiter          XML-style tag delimiters

		["@punctuation.bracket"] = { fg = palette.bg5 },
		["@constructor"] = { fg = palette.fg3 },
		["@keyword.function"] = { fg = palette.fg5 },
		["@keyword.modifier"] = { fg = palette.fg5 },
		["@variable"] = { fg = palette.fg2 },
		["@variable.member"] = { fg = palette.fg5 },
		["@keyword.conditional"] = { fg = palette.fg6 },
		["@punctuation.delimiter"] = { fg = palette.mid },
		["@type.builtin"] = { fg = palette.fg3 },
		["@variable.builtin"] = { fg = palette.norm3, bold = true },
		["@string.documentation"] = { link = "Comment" },
		["@tag"] = { fg = palette.mid },
		["@tag.attribute"] = { fg = palette.fg4 },
		["@tag.delimiter"] = { fg = palette.bg5 },
		["@comment.documentation"] = { fg = palette.doc_comment },


		-- treesitter lua {{{
		["@constructor.lua"] = { fg = palette.base4 },
		["@keyword.lua"] = { fg = palette.bg6 },

		-- tressiter gleam
		["@constructor.gleam"] = { link = "Constant" },

		-- treesitter rust {{{
		["@function.macro.rust"] = { fg = palette.norm2 },
		["@keyword.rust"] = { fg = palette.keyword },
		["@keyword.type.rust"] = { fg = palette.keyword },

		-- lsp stuff
		["@lsp.mod.static"] = { italic = true },
		["@lsp.type.enum"] = { fg = palette.fg7 },
		-- make special case for lua if this interfers with other languages
		["@lsp.type.type"] = { fg = palette.doc_comment },
		["@lsp.type.comment"] = { fg = palette.doc_comment },
		["@lsp.mod.documentation"] = { fg = palette.doc_comment },

		LspReferenceWrite = { bg = palette.fn, fg = palette.dark },
		LspReferenceRead = { bg = palette.cursor_line },
		LspReferenceText = { bold = true },

		-- lsp rust
		["@lsp.typemod.derive.defaultLibrary.rust"] = { fg = palette.fg4 },
		["@lsp.type.enum.rust"] = { link = "@lsp" },
	}
end

-- Autocommands (source: https://github.com/folke/tokyonight.nvim/blob/f9e738e2dc78326166f11c021171b2e66a2ee426/lua/tokyonight/util.lua#L67)
local augroup = vim.api.nvim_create_augroup("gray-base", { clear = true })
vim.api.nvim_create_autocmd("ColorSchemePre", {
	group = augroup,
	callback = function()
		vim.api.nvim_del_augroup_by_id(augroup)
	end,
})

local function set_whl()
	local win = vim.api.nvim_get_current_win()
	local whl = vim.split(vim.wo[win].winhighlight, ",")
	vim.list_extend(whl, { "Normal:NormalSB", "SignColumn:SignColumnSB", "WinSeparator:WinSeparatorSB" })
	whl = vim.tbl_filter(function(hl)
		return hl ~= ""
	end, whl)
	vim.opt_local.winhighlight = table.concat(whl, ",")
end

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "qf", "lazy", "mason", "help", "oil", "undotree", "diff", "gitcommit" },
	callback = set_whl,
})
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = set_whl,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "cs" },
	callback = function()
		vim.print("cs file")
		-- TODO: lower semantics prio when ft from config array
		-- vim.highlight.priorities.semantic_tokens = 70
	end,
})

local M = {}

---converts x to an hsl table if x is an integer
---if x is an table, it will assert that hue is set
---@param x integer | HslColor
---@param opts table
---@return HslColor
local function convert_to_object(x, opts)
	if type(x) == "number" then
		return {
			hue = x,
			saturation = opts.colors.saturation,
			lightness = opts.colors.lightness,
		}
	elseif type(x) == "table" then
		assert(x.hue ~= nil, "the hue field is required")

		if x.saturation == nil then
			x.saturation = opts.colors.saturation
		elseif x.lightness == nil then
			x.lightness = opts.colors.lightness
		end
		return x
	end
	return {}
end

---loads the colorscheme and merges config
---@param opts table
M.load = function(opts)
	-- override the base options with dark or light if there is any
	if is_dark() == true and opts ~= nil then
		opts = vim.tbl_deep_extend("force", opts, opts.dark or {})
	else
		opts = vim.tbl_deep_extend("force", opts, opts.light or {})
	end

	opts.colors.primary = convert_to_object(opts.colors.primary, opts)
	opts.colors.secondary = convert_to_object(opts.colors.secondary, opts)
	opts.colors.accent = convert_to_object(opts.colors.accent, opts)
	opts.colors.strings = convert_to_object(opts.colors.strings, opts)
	opts.colors.cursor = convert_to_object(opts.colors.cursor, opts)

	local hlgroups = generate_hlgroups(opts)
	for group, hl in pairs(hlgroups) do
		vim.api.nvim_set_hl(0, group, hl)
	end
end

return M
