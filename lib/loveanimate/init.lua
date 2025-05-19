local la = { _VERSION = "0.1.0" }
print("Loaded LoveAnimate v" .. la._VERSION)

local AnimateAtlas = require("loveanimate.AnimateAtlas")
local SparrowAtlas = require("loveanimate.SparrowAtlas")

---
--- @deprecated
--- @return love.animate.AnimateAtlas
---
function la.newAtlas()
    print("love.animate.newAtlas is deprecated, use love.animate.newTextureAtlas instead!")
    return la.newTextureAtlas()
end

---
--- @return love.animate.AnimateAtlas
---
function la.newTextureAtlas()
    return AnimateAtlas:new()
end

---
--- @return love.animate.SparrowAtlas
---
function la.newSparrowAtlas()
    return SparrowAtlas:new()
end

love.animate = la