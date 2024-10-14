local config = {
	tint = {
		hue = 210,
		saturation = 2,
	},
	colors = {
		-- hue of the primary color, the color used for fuctions etc.
		primary = 42,
		-- hue of the secondary color, used for constants and numbers
		secondary = 210,
		-- staturation of every color
		saturation = 30,
		luminance = 60,
	},
	grays = {},
	cursor = {},
	-- override capture or highligt groups
	-- accepts a hue value or a hex string
	-- a hue value will respect the sarutation and luminance set in "colors"
	-- while a hex string will not, so use a hex value if you want an absolute value that
	-- the rest of the config dont have any impact over
	overrides = {
		["@variable"] = 23, -- works with a hue value, 0 - 360
		["@varialbe.rust"] = "#FFF000", -- works with a #hex value
	},
	-- how much the light and dark variant of a color shoud variy
	-- this variance i rary used
	luminance_variance = 10,
	-- override the semantic hightlights from the lsp
	override_lsp_semantics = true,
	-- the priority to set when 'override_lsp_semantics' is set to true
	lsp_semantics_prio = 95,

	gutter_diagnostics_saturation = 40,
	gutter_gitsigns_saturation = 40,
	lualine_saturation = 40,

	preset = "default",

	-- overrides for darkmode, all the base options except preset can be overridden
	-- a value overriden in dark will always have precidence over the base when bg="dark"
	dark = {},
	-- overrides for lightmode, all the base options except preset can be overridden
	-- a value overriden in light will always have precidence over the base when bg="light"
	light = {},
}

local config_blue = {
	dark = {
		colors = {
			primary = 200,
		},
	},
	light = {
		colors = {
			primary = 200,
		},
	},
}

local purple_haze = {
	dark = {
		colors = {
			primary = 232,
			secondary = 42,
		},
	},
	light = {
		colors = {
			primary = 232,
			primary = 42,
		},
	},
}

local M = {}

M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
	-- merge all the settings
	-- precidence should be "user config" ->
	M.config = vim.tbl_deep_extend("force", M.config, args or {})

	-- if args.preset ~= nil and args.preset ~= "default" then
	-- 	M.config = vim.tbl_deep_extend("force", M.config, purple_haze)
	-- end
end

M.load = function()
	vim.print(M.config)
	require("gray-base.theme").load(M.config)
end

return M
