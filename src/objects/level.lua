Level = class({
	name = "Level"
})

Level.type = "level"

local parsers = {
	tilelayer = function() end,
	objectgroup = function(self, map_lua, layer)
		for _,object in pairs(layer.objects) do
			if object.shape == "rectangle" then
				table.insert(self.world_group,
					Slick.newBoxShape(object.x, object.y, object.width, object.height)
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
}

function Level:new(x, y, map_lua)
	self.x = x or 0
	self.y = y or 0

	self.width = map_lua.width
	self.height = map_lua.height
	self.tilewidth = map_lua.tilewidth
	self.tileheight = map_lua.tileheight

	self.boxes = {}
	self.polygons = {}

	self.world_group = {}

	for i, layer in pairs(map_lua.layers) do
		parsers[layer.type](self, map_lua, layer)
	end

	if #self.world_group then
		World:add(self, self.x, self.y, Slick.newShapeGroup(unpack(self.world_group)))
	end
end

function Level:draw()
	if not DEBUG then return end

	for k,v in pairs(self.boxes) do
		love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
	end
	for k,v in pairs(self.polygons) do
		love.graphics.polygon("line", unpack(v))
	end
end