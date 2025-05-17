local PowerUp = class{
	name = "PowerUp",
	extends = require("objects.GameObject")
}

-- TODO: finish

local POWERUP_TYPES = {}

POWERUP_TYPES["mushroom"] = {
	canMove = false,
	canBounce = false,
	collect = function(self, player) end
}

return PowerUp