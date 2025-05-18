local GameObject = require "objects.GameObject"
local Tile = class{name = "Tile", extends = GameObject}

function Tile:new(x, y, tile, tileset, properties)
	self.width = tileset.tilewidth
	self.height = tileset.tileheight
	self.tileset = tileset
	self.tile = tile

	self.cols = {
		type = "aabb",
		onOverlap = function() end,
		onResolve = function() end
	}

	if self.tile.slope == "true" then
		self.cols.type = "slope"
	end

	self:super(x, y)
end

function Tile:physics() end

function Tile:draw()
	love.graphics.draw(self.tileset.image, self.tile.quad,
		self.x,
		self.y)
end

return Tile