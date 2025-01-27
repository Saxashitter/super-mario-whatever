local TileSet = require("objects.tilemap.TileSet")

local Level = class({
	name = "Level",
	extends = GameObject
})

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
					y = object.y
				})
			else
				if object.shape == "rectangle" then
					table.insert(self.world_group,
						Slick.newRectangleShape(object.x, object.y, object.width, object.height)
					)
					table.insert(self.boxes, object)
				end
				if object.shape == "polygon" then
					local polygons = {}
		
					for k,v in ipairs(object.polygon) do
						table.insert(polygons, object.x+v.x)
						table.insert(polygons, object.y+v.y)
					end
		
					table.insert(self.world_group,
						Slick.newPolygonShape(polygons)
					)
					table.insert(self.polygons, polygons)
				end
			end
		end
	end
}

Level.alwaysDraw = true

function Level:new(x, y, map_lua)
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

	for k,v in ipairs(map_lua.tilesets) do
		table.insert(self.tilesets, TileSet(v))
	end

	self.world_group = {}

	for i, layer in pairs(map_lua.layers) do
		parsers[layer.type](self, map_lua, layer)
	end

	if #self.world_group >= 1 then
		World:add(self, self.x, self.y, Slick.newShapeGroup(unpack(self.world_group)))
	end
end

function Level:update(dt) end
function Level:physics() end

function Level:draw()
	local x,y,w,h = 0,0,GAME_WIDTH,GAME_HEIGHT

	if self.camera then
		local scale
		x, y, scale = self.camera:getPosition()
		w, h = GAME_WIDTH/scale, GAME_HEIGHT/scale
	
		x = x-w/2
		y = y-h/2
	end

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

return Level