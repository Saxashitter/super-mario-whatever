local TileSet = require("objects.tilemap.TileSet")

local Level = class({
	name = "Level",
	extends = GameObject
})

Level.collide = false

local parsers = {
	tilelayer = function(self, map_lua, layer)
		for i,id in pairs(layer.data) do
			if id > 0 then
				local tileset,tileid
				-- find what tileset this belongs to
				for k,v in pairs(self.tilesets) do
					local tile,_tileid = v:getTile(id)
					
					if tile then
						tileset = v
						tileid = _tileid
						break
					end
				end

				if tileset == nil then
					error "No tileset!"
				end

				local x = math.floor((i - 1) % map_lua.width)
				local y = math.floor((i - 1) / map_lua.width)

				if not self.tiles[y] then
					self.tiles[y] = {}
				end
				self.tiles[y][x] = tileset:createTile(tileid, x*self.tilewidth, y*self.tileheight)
				-- TODO: add layer support, which should be easy
			end
		end
	end,
	objectgroup = function(self, map_lua, layer)
		for _,object in pairs(layer.objects) do
			if object.name == "camera" then
				table.insert(self.cameras, {
					x = object.x,
					y = object.y,
					width = object.width,
					height = object.height
				})
			elseif object.name == "marker" then
				if not self.markers[object.type] then
					self.markers[object.type] = {}
				end
	
				table.insert(self.markers[object.type], {
					x = object.x,
					y = object.y,
					properties = object.properties
				})
			elseif object.name == "music_change" then
				table.insert(self.songs, {
					x = object.x,
					y = object.y,
					path = object.type
				})
			else
				if object.shape == "rectangle" then
					table.insert(self.boxes, object)
				end
				if object.shape == "polygon" then
					local polygons = {}
		
					for k,v in ipairs(object.polygon) do
						table.insert(polygons, object.x+v.x)
						table.insert(polygons, object.y+v.y)
					end

					table.insert(self.polygons, polygons)
				end
			end
		end
	end
}

Level.alwaysDraw = true

function Level:new(x, y, map_lua, world)
	self.x = y or 0
	self.y = x or 0
	self.width = map_lua.width
	self.height = map_lua.height
	self.tilewidth = map_lua.tilewidth
	self.tileheight = map_lua.tileheight
	self.properties = map_lua.properties
	self.tilesets = {}
	self.tiles = {}
	self.markers = {}

	self.cameras = {}
	self.boxes = {}
	self.polygons = {}
	self.songs = {}

	for k,v in ipairs(map_lua.tilesets) do
		table.insert(self.tilesets, TileSet(v))
	end

	for i, layer in pairs(map_lua.layers) do
		parsers[layer.type](self, map_lua, layer)
	end

	if world then
		self.world = world
		self.world_objects = {}
		for _, y in pairs(self.tiles) do
			for _,tile in pairs(y) do
				world:add(tile)
				table.insert(self.world_objects, tile)
			end
		end
	end
end

function Level:update(dt) end
function Level:physics() end

function Level:draw(x,y,w,h)
	local x1 = math.floor(x/self.tilewidth)
	local y1 = math.floor(x/self.tileheight)
	local x2 = math.floor((x+w)/self.tilewidth)
	local y2 = math.floor((y+h)/self.tileheight)

	--[[for y = y1, y2 do
		if self.tiles[y] then
			for x = x1, x2 do
				if self.tiles[y][x] then
					self.tiles[y][x]:draw()
				end
			end
		end
	end]]
	for y,t in pairs(self.tiles) do
		for x,t in pairs(t) do
			t:draw()
		end
	end

	if not DEBUG then return end

	for k,v in pairs(self.boxes) do
		love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
	end
	for k,v in pairs(self.polygons) do
		love.graphics.polygon("line", unpack(v))
	end
end

function Level:isInCamera(object)
	for k,cam in pairs(self.cameras) do
		if object.x + object.width >= cam.x
		and object.x <= cam.x+cam.width
		and object.y + object.height >= cam.y
		and object.y <= cam.y + cam.height then
			return cam
		end
	end
end

local function _getSlopePosition(x,y,w,h, box)
	local ly = tonumber(box.tile.slope_left)
	local ry = tonumber(box.tile.slope_right)
	local side = ry > ly
	local lerp = math.max(0, math.min((x-box.x)/box.width, 1))

	if not side then
		lerp = 1-math.max(0, math.min(((box.x+box.width)-(x+w))/box.width, 1))
	end

	return box.y+mathx.lerp(ly, ry, lerp)
end

local function _isTileColliding(x,y,w,h, box)
	if box.tile.slope == "true" then
		local slopeY = _getSlopePosition(x,y,w,h, box)

		return x+w > box.x
		and y+h > slopeY
		and x < box.x+box.width
		and y < box.y+box.height
	end
	return x+w > box.x
	and y+h > box.y
	and x < box.x+box.width
	and y < box.y+box.height
end

local function _resolveCollision(x,y,w,h, box, type, sloped)
	local omx = x+w/2
	local omy = y+h/2
	local bmx = box.x+box.width/2
	local bmy = box.y+box.height/2

	if type then
		if box.tile.slope ~= "true" then
			local oy = omy
			local by = bmy

			if oy < by then
				oy = oy + h/2
				by = by - box.height/2
			else
				oy = oy - h/2
				by = by + box.height/2
			end

			if math.abs(oy-by) < box.height/4
			and sloped then
				if omy > bmy then
					return x, box.y+box.height
				end
	
				return x, box.y-h
			end

			if omx > bmx then
				return box.x+box.width, y
			end

			return box.x-w, y
		end
		local newY = _getSlopePosition(x,y,w,h, box)-h

		local ly = tonumber(box.tile.slope_left)
		local ry = tonumber(box.tile.slope_right)
		local side = ry > ly
		local tx = side and box.x or box.x+box.width

		if not side then
			if x+w/2 > tx then
				return box.x+box.width, y
			end
		else
			if x+w/2 < tx then
				return box.x-w, y
			end
		end

		if y+h > box.y+box.height then
			if omx > bmx then
				return box.x+box.width, y
			end
			return box.x-w, y
		end

		return x, newY, true
	end

	if omy > bmy then
		return x, box.y+box.height
	end

	local by = box.y
	if box.tile.slope == "true" then
		by = _getSlopePosition(x,y,w,h, box)
	end

	return x, by-h
end

function Level:moveAndCheck(object)
	local x, y = object.x, object.y
	local w,h = object.width, object.height

	local grounded = object:isOnGround()
	local xSteps = math.floor(math.abs(object.momx)/(self.tilewidth/24))+1
	local ySteps = math.floor(math.abs(object.momy)/(self.tileheight/24))+1

	local xCols = false
	local yCols = false

	-- first step x, and then y
	for i = 1,xSteps do
		x = x+object.momx/xSteps

		for ty = math.floor(y/self.tileheight),math.ceil((y+h)/self.tileheight) do
			for tx = math.floor(x/self.tilewidth),math.ceil((x+w)/self.tilewidth) do
				local tile = self.tiles[ty] and self.tiles[ty][tx]

				if tile
				and tile.tile.collide == "true"
				and _isTileColliding(x,y, object.width, object.height, tile) then
					local keep
					x, y, keep = _resolveCollision(x,y,object.width,object.height, tile, true)
					if not keep then
						xCols = true
					end
				end
			end
		end

		if grounded then
			-- we should check for a slope/half tile under us
			local collisions = self:getCols(x,y+object.height,object.width,4)
			local newY = y
			if #collisions > 0 then
				newY = y+8
				xCols = false
			end
	
			for _,tile in pairs(collisions) do
				local objY = tile.y
	
				if tile.tile.slope == "true" then
					objY = _getSlopePosition(x,y,object.width,object.height, tile)
				end
	
				newY = math.min(objY-h, newY)
			end
	
			y = newY
		end

		if xCols then break end
	end
	for i = 1,ySteps do
		y = y+object.momy/ySteps

		for ty = math.floor(y/self.tileheight),math.ceil((y+h)/self.tileheight) do
			for tx = math.floor(x/self.tilewidth),math.ceil((x+w)/self.tilewidth) do
				local tile = self.tiles[ty] and self.tiles[ty][tx]

				if tile
				and tile.tile.collide == "true"
				and _isTileColliding(x,y, object.width, object.height, tile) then
					x, y = _resolveCollision(x,y,object.width,object.height, tile)
					yCols = true
				end
			end
		end

		if yCols then break end
	end

	return x, y, xCols, yCols
end

function Level:getCols(x,y,w,h)
	local collisions = {}

	for ty = math.floor(y/self.tileheight),math.ceil((y+h)/self.tileheight) do
		for tx = math.floor(x/self.tilewidth),math.ceil((x+w)/self.tilewidth) do
			local tile = self.tiles[ty] and self.tiles[ty][tx]

			if tile
			and tile.tile.collide == "true"
			and _isTileColliding(x,y,w,h, tile) then
				table.insert(collisions, tile)
			end
		end
	end

	return collisions
end

return Level