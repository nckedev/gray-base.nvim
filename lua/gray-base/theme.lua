vim.highlight.priorities.semantic_tokens = 95

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

local function clamp(x, max)
	if x > max then
		return 100
	elseif x < 0 then
		return 0
	else
		return x
	end
end

---@param h number hue
---@param s number sat
---@param l number lum
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

local function gray(x, opts)
	--if lightmode, invert the gray colors
	if is_dark() == false then
		x = 100 - x
	end

	return hsl(opts.tint.hue, opts.tint.saturation, x)
end

local function generate_variants(h, opts)
	local l = 60
	local variance = opts.luminance_variance
	local s = opts.colors.saturation

	return {
		default = hsl(h, s, l),
		dark = hsl(h, s, l - variance),
		light = hsl(h, s, l + variance),
		strong = hsl(h, 100, 50),
	}
end

local function generate_colors(opts)
	local colors = {
		orange = 42,
		blue = 210,
		purple = 232,
		green = 85,
		red = 0,
		yellow = 50,
	}
	return {

		grays = {
			min = gray(0, opts),
			max = gray(100, opts),
			hidden = gray(26, opts),

			base1 = gray(12, opts),
			base2 = gray(15, opts),
			base3 = gray(27, opts),
			base4 = gray(38, opts),

			mid_bg = gray(45, opts),
			mid = gray(55, opts),
			mid_fg = gray(55, opts),

			norm1 = gray(65, opts),
			norm2 = gray(70, opts),
			norm3 = gray(80, opts),
			norm4 = gray(85, opts),
		},

		primary = generate_variants(opts.colors.primary, opts),
		secondary = generate_variants(opts.colors.secondary, opts),
		purple = generate_variants(colors.purple, opts),
		red = generate_variants(colors.red, opts),
		green = generate_variants(colors.green, opts),
		orange = generate_variants(colors.orange, opts),
		yellow = generate_variants(colors.yellow, opts),
	}
end

local function generate_palette(opts)
	local colors = generate_colors(opts)

	return {
		base1 = colors.grays.base1,
		base2 = colors.grays.base2,
		base3 = colors.grays.base3,
		base4 = colors.grays.base4,

		hidden = colors.grays.hidden,
		mid = colors.grays.mid,

		norm1 = colors.grays.norm1,
		norm2 = colors.grays.norm2,
		norm3 = colors.grays.norm3,
		norm4 = colors.grays.norm4,

		accent = colors.primary.dark,

		fn = colors.primary.default,

		cursor_line = colors.grays.base2,
		comment = colors.grays.hidden,
		oob = colors.grays.min,
		cursor = colors.green.dark,

		visual = colors.grays.norm1,
		literal = colors.grays.mid_bg,
		number = colors.secondary.default,

		add = colors.green.default,
		change = colors.orange.default,
		delete = colors.red.default,

		error = colors.red.default,
		warn = colors.orange.default,
		hint = colors.grays.norm1,
		info = colors.grays.norm1,
		ok = colors.norm_subtle,
	}
end

local function generate_hlgroups(opts)
	local palette = generate_palette(opts)
	return {
		-- normal {{{
		Normal = { fg = palette.norm1, bg = palette.base1 },
		NormalFloat = { fg = palette.norm1, bg = palette.base3 },
		NormalBorder = { link = "NormalFloat" },

		Comment = { fg = palette.hidden, italic = true },
		SpecialComment = { link = "Comment" },
		Critical = { fg = palette.bg, bg = palette.accent, bold = true },
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
		Identifier = { fg = palette.norm1 },

		Statement = { fg = palette.norm2, bold = false },
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

		Type = { fg = palette.norm3, underline = false },
		StorageClass = { link = "Type" },
		Structure = { link = "Type" },
		Typedef = { link = "Type" },

		Operator = { fg = palette.mid },
		Debug = { link = "Operator" },

		Special = { fg = palette.norm1, italic = true },
		SpecialChar = { link = "Special" },
		Tag = { link = "Special" },
		Delimiter = { link = "Special" },

		Underlined = { underline = true },
		Ignore = { fg = palette.norm_very_subtle },
		Error = { reverse = true, bold = true },
		Todo = { fg = palette.accent, italic = true },
		--}}}
		-- spell {{{
		SpellBad = { undercurl = true, sp = palette.norm1 },
		SpellCap = { link = "SpellBad" },
		SpellLocal = { link = "SpellBad" },
		SpellRare = { link = "SpellBad" },
		--}}}
		-- ui {{{
		ColorColumn = { link = "CursorLine" },
		Conceal = { link = "Comment" },
		CurSearch = { bg = palette.norm2, fg = palette.base2 },
		Cursor = { fg = palette.oog, bg = palette.cursor },
		CursorColumn = { link = "CursorLine" },
		CursorLine = { bg = palette.cursor_line },
		CursorLineNr = { fg = palette.base3, bg = palette.cursor_line, bold = false },
		EndOfBuffer = { link = "Normal" },
		ErrorMsg = { fg = palette.accent, bold = true },
		FloatBorder = { fg = palette.base2, bg = palette.base2 },
		FloatTitle = {
			fg = palette.norm_subtle,
			bg = palette.base2,
			bold = true,
			underline = true,
		},
		FoldColumn = { link = "SignColumn" },
		Folded = { fg = palette.norm1, bg = palette.bg, bold = true },
		IncSearch = { link = "CurSearch" },
		LineNr = { fg = palette.hidden },
		MatchParen = { fg = palette.norm3, bold = true },
		ModeMsg = { fg = palette.norm1, bold = true },
		MoreMsg = { fg = palette.norm1, bold = true },
		MsgArea = { fg = palette.norm1, bg = palette.base1 },
		NonText = { fg = palette.mid },
		NormalNC = { link = "Normal" },
		NvimInternalError = { link = "ErrorMsg" },
		Pmenu = { bg = palette.base3 },
		PmenuSbar = { bg = palette.base2, reverse = true },
		PmenuKind = { bg = palette.base2 },
		PmenuSel = { fg = palette.norm1, bg = palette.base2, reverse = true, bold = false },
		PmenuKindSel = { fg = palette.literal, bg = palette.base2, reverse = true, bold = true },
		Question = { bold = true },
		QuickFixLine = { link = "Visual" },
		Search = { bg = palette.accent, fg = palette.base1 },
		SignColumn = { bg = palette.bg, fg = palette.norm1, bold = true },
		SpecialKey = { fg = palette.norm_subtle },
		StatusLine = { fg = palette.norm1, bg = palette.cursor_line },
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
		Added = { fg = palette.base1, bg = palette.add },
		Changed = { fg = palette.base1, bg = palette.change },
		Removed = { fg = palette.base1, bg = palette.delete },
		Deleted = { fg = palette.base1, bg = palette.delete },

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
		-- treesitter {{{
		["@string.documentation"] = { link = "Comment" },
		["@keyword.function.julia"] = { bold = true },
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
		TelescopeSelection = { bg = palette.base1 },
		TelescopeMatching = { fg = palette.fn },
		TelescopePromptNormal = { fg = palette.normal, bg = palette.base3 },
		TelescopePromptBorder = { fg = palette.normal, bg = palette.base3 },
		TelescopeResultsNormal = { bg = palette.base2 },
		TelescopeResultsBorder = { bg = palette.base2 },
		TelescopeResultsTitle = { bg = palette.base2, fg = palette.base2 },
		TelescopePromptTitle = { bg = palette.fn, fg = palette.base1 },
		TelescopeSelectionCaret = { fg = palette.green },
		--}}}
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
		NormalSB = { fg = palette.norm1, bg = palette.oob },
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
		-- HACK:
		-- FIX: asdf
		-- PERF: asdf

		-- Todo comment
		TodoBgNOTE = { bg = palette.number, fg = palette.base1 },
		TodoFgNOTE = { fg = palette.number },

		-- TODO  mer gul
		TodoBgTODO = { bg = palette.warn, fg = palette.base1 },
		TodoFgTODO = { fg = palette.warn },

		--treesitter stuff
		["@punctuation.bracket"] = { fg = palette.base4 },
		["@constructor"] = { fg = palette.norm3 },
		["@keyword.function"] = { fg = palette.norm1 },
		["@keyword.modifier"] = { fg = palette.mid },
		["@variable"] = { fg = palette.norm4 },

		-- treesitter lua {{{
		["@keyword.conditional"] = { link = "Operator" },
		["@variable.member.lua"] = { link = "Identifier" },
		["@constructor.lua"] = { fg = palette.base4 },
		-- }}}

		-- treesitter rust {{{
		["@punctuation.delimiter"] = { fg = palette.mid },
		["@type.builtin"] = { fg = palette.norm2 },
		["@variable.builtin"] = { fg = palette.norm3, bold = true },
		["@function.macro.rust"] = { fg = palette.norm2 },
		["@keyword.rust"] = { fg = palette.fn },
		["@keyword.type.rust"] = { fg = palette.fn },
		-- }}}

		-- lsp stuff
		LspReferenceWrite = { fg = palette.fn, bold = true },
		LspReferenceRead = { fg = palette.norm3, bold = true },
		LspReferenceText = { bold = true },
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

-- Here's the function you want --
local M = {}

M.load = function(opts)
	if is_dark() == true then
		o = opts.dark
	else
		o = opts.light
	end

	o.luminance_variance = opts.luminance_variance

	print(vim.inspect(o))

	local hlgroups = generate_hlgroups(o)
	for group, hl in pairs(hlgroups) do
		vim.api.nvim_set_hl(0, group, hl)
	end
end

return M