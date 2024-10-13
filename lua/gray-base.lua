local config = {
	-- sets the tint of all the gray colors
	dark = {
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
		},
	},
	light = {
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
			saturation = 40,
		},
	},

	-- how much the light and dark variant of a color shoud variy
	-- this variance i rary used
	luminance_variance = 10,
}

local M = {}

M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
	M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.load = function()
	require("gray-base.theme").load(M.config)
end

return M
