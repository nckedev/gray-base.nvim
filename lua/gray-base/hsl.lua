Hsl = {}
Hsl.__index = Hsl

local function clamp(x, max)
	if x > max then
		return 100
	elseif x < 0 then
		return 0
	else
		return x
	end
end

function Hsl:new(h, s, l)
	local hsl = {}
	setmetatable(hsl, Hsl)
	hsl.h = clamp(h, 360)
	hsl.s = clamp(s, 100)
	hsl.l = clamp(l, 100)
	return hsl
end

function Hsl:with_saturation(s)
	self.s = s
	return self
end

function Hsl:with_luminace(l)
	self.l = l
	return self
end

function Hsl.to_hex(hsl)
	return "#str"
end
