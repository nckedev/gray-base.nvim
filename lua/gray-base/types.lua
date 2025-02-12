---@alias hslTable { hue: integer, saturation:integer, lightness:integer}

---@class (exact) HslColor
---@field hue integer
---@field saturation integer
---@field lightness integer
---
---@class Tint
---@field hue integer
---@field saturation integer

---@class (exact) HslColorWithVariance
---@field Dmonochrome HslColor
---@field Ddefault HslColor
---@field Ddark HslColor
---@field Dlight HslColor
---@field Dstrong HslColor


---@class (exact) Options
---@field tint Tint
---@field colors { primary : HslColor, secondary : HslColor , accent: HslColor, strings : HslColor , cursor : HslColor , saturation : integer, lightness: integer}
---@field grays {min: integer, max : integer}
---@field inverted_lightness boolean
---@field hl_overrides table<string, integer | string>
---@field lightness_variance  integer
---@field disable_lsp_semantic_hl  table<string>
---@field gutter_diagnostics_saturation  integer
---@field gutter_gitsigns_saturation  integer
---@field lualine_saturation  integer
---@field preset string
---@field dark table
---@field light table
