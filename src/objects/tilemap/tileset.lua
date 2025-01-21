TileSet = class{name = "TileSet"}

function TileSet:new(properties)
	self.tiles = {}
	self.image = love.graphics.newImage("assets/images/tilesets/"..properties.image)
	self.image:setFilter("nearest")
	self.tilewidth = properties.grid.width
	self.tileheight = properties.grid.height
	self.firstgid = properties.firstgid

	local x = 0
	local y = 0
	local tiles = 0

	while y < self.image:getHeight() do
		while x < self.image:getWidth() do
			table.insert(self.tiles, {
				quad = love.graphics.newQuad(
					x-1,
					y,
					properties.grid.width,
					properties.grid.height,
					self.image)
				}
			)
			tiles = tiles + 1
			x = x + properties.grid.width + properties.spacing
		end
		y = y + properties.grid.height + properties.spacing
		x = -16 -- IM DUMB TO FIX THIS RN
	end

	for _,tile in pairs(properties.tiles) do
		if self.tiles[tile.id] then
			for i,property in pairs(tile.properties) do
				self.tiles[tile.id][i] = property
				print("set property for tile "..tile.id)
			end
		end
	end
end

function TileSet:getTile(id)
	local _id = id - self.firstgid + 1

	if self.tiles[_id] then
		return self.tiles[_id], _id
	end
end

function TileSet:createTile(id, x, y)
	if not self.tiles[id] then return false end

	return Tile(x, y, self.tiles[id], self)
end