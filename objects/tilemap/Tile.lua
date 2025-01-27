local GameObject = require "objects.GameObject"
local Tile = class{name = "Tile", extends = GameObject}

function Tile:defineShape()
	return Slick.newRectangleShape(0,0,self.width,self.height)
end

function Tile:new(x, y, tile, tileset)
	self.width = tileset.tilewidth
	self.height = tileset.tileheight
	self.tileset = tileset
	self.tile = tile

	self:super(x, y, true)
end

function Tile:physics() end

function Tile:draw()
	love.graphics.draw(self.tileset.image, self.tile.quad,
		math.floor(self.x),
		math.floor(self.y))
end

return Tile