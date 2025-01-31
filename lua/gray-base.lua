local config = {
	-- sets a tint color for all the gray values
	tint = {
		hue = 210,
		saturation = 2,
	},
	colors = {
		-- hue of the primary color, the color used for fuctions etc.
		-- the value can be a number (hue) or an object {hue, saturation, lightness }
		-- if the value is a number the saturation and lightness of the color object is used.
		primary = 42,
		-- hue of the secondary color, used for constants and numbers
		secondary = 210,
		-- hue of the accent color, used for matches in searches and places where you need a contrasting color to grab attention
		accent = 300,
		-- hue of strings, only works if use_colored_strings is set to true.
		strings = { hue = 85, saturation = 0, lightness = 60 },
		cursor = { hue = 85, saturation = 40, lightness = 50 },
		-- staturation of every color
		saturation = 30,
		lightness = 60,
	},
	-- sets the min and max lightness of the gray colors. 0 is the darkest when bg = dark and 0 is the brightest when bg = light,
	-- the grayscale is baisclly inverted when switching mode
	-- the colorschem generates 15 gray shades in between min and max, so so max - min has to be over 15
	-- so if you want a background that is fully black and the max bright fg color is gray, set min to 0 and max to 50
	grays = {
		min = 15,
		max = 85,
	},
	-- override capture or highligt groups
	-- accepts a hue value or a hex string
	-- a hue value will respect the sarutation and luminance set in "colors"
	-- while a hex string will not, so use a hex value if you want an absolute value that
	-- the rest of the config dont have any impact over
	hl_overrides = {
		-- ["@variable"] = 23, -- works with a hue value, 0 - 360
		-- ["@varialbe.rust"] = "#FFF000", -- works with a #hex value
	},
	-- how much the light and dark variant of a color shoud variy
	-- this variance i rary used
	lightness_variance = 10,
	-- override the semantic hightlights from the lsp
	disable_lsp_semantic_hl = { "cs" },
	-- the priority to set when 'override_lsp_semantics' is set to true

	gutter_diagnostics_saturation = 40,
	gutter_gitsigns_saturation = 40,
	lualine_saturation = 40,

	preset = "default",

	-- overrides for darkmode, all the base options except preset can be overridden
	-- a value overriden in dark will always have precidence over the base when bg="dark"
	dark = {},
	-- overrides for lightmode, all the base options except preset can be overridden
	-- a value overriden in light will always have precidence over the base when bg="light"
	light = {
		secondary = {
			hue = 210,
			lightness = 50,
		},
	},
}

local presets = {

	["config_blue"] = {
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
	},

	["purple_haze"] = {
		dark = {
			colors = {
				primary = 232,
				secondary = 42,
			},
		},
		light = {
			colors = {
				primary = 232,
				secondary = 42,
			},
		},
	},

	["lucy"] = {
		tint = { hue = 50, saturation = 2 },
		colors = {
			primary = 309,
			secondary = 50,
		},
	},
}

local M = {}

M.config = config
M.presets = presets

---@param args table
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
	-- default config
	local config = M.config

	-- override with preset if set
	if args.preset ~= nil and args.preset ~= "default" then
		config = vim.tbl_deep_extend("force", config, M.presets[args.preset] or {})
	end

	-- override with user config if set
	config = vim.tbl_deep_extend("force", config, args or {})

	M.config = config
end

M.load = function()
	require("gray-base.theme").load(M.config)
end

return M
