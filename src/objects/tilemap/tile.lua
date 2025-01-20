Tile = class{name = "Tile", extends = GameObject}

function Tile:defineShape()
	return Slick.newRectangleShape(0,0,self.width,self.height)
end

function Tile:new(x, y, tile, tileset)
	self.width = tileset.tilewidth
	self.height = tileset.tileheight
	self.tileset = tileset
	self.tile = tile

	if self.tile.collide == "true" then
		print "YAY HITBOX"
	end

	self:super(x, y, self.tile.collide ~= "true")
end

function Tile:physics() end

function Tile:draw()
	love.graphics.draw(self.tileset.image, self.tile.quad, self.x, self.y)
end