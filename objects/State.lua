local State = class{name = "State"}
State._chunk_size = 64

local function object_sort(a, b)
	local id1 = self._object_indexes[a]
	local id2 = self._object_indexes[b]

	return id1 < id2
end

function State:new()
	self._objects = {}
	self._object_indexes = {}
	self._object_viewport = {}

	self._viewports = {}
	self._viewports_indexes = {}

	self._object_positions = {}
	self._always_draw = {}
end

function State:remove(object)
	if self._object_indexes[object] == nil then
		return
	end

	table.remove(self._objects, self._object_indexes[object])
	self._object_indexes[object] = nil
end

function State:add(object)
	if self._object_indexes[object] then
		return
	end

	table.insert(self._objects, object)
	self._object_indexes[object] = #self._objects
end

function State:addViewport(viewport)
	if self._viewports_indexes[viewport] then return end

	table.insert(self._viewports, viewport)
	self._viewports_indexes[viewport] = #self._viewports
end

function State:removeViewport(viewport)
	if not self._viewports_indexes[viewport] then return end

	table.remove(self._viewports, self._viewports_indexes)
	self._viewports_indexes[viewport] = nil
end

function State:bindObjectToViewport(viewport, object)
	if not self._viewports_indexes[viewport] then return end
	if not self._object_indexes[object] then return end

	self._object_viewport[object] = viewport
end

function State:update(dt)
	self._object_positions = {}
	self._always_draw = {}
	for i,object in pairs(self._objects) do
		if object.physics then
			object:physics(dt)
		end
		if object.update then
			object:update(dt)
		end

		if object.alwaysDraw then
			table.insert(self._always_draw, object)
		else
			local x = math.floor(object.x/self._chunk_size)
			local y = math.floor(object.y/self._chunk_size)
			local width = math.floor(object.width/self._chunk_size)
			local height = math.floor(object.height/self._chunk_size)
	
			for yi = 0,height do
				for xi = 0,width do
					local x = x+xi
					local y = y+yi
	
					if not self._object_positions[y] then
						self._object_positions[y] = {}
					end
					if not self._object_positions[y][x] then
						self._object_positions[y][x] = {}
					end
		
					table.insert(self._object_positions[y][x], object)
				end
			end
		end
	end

	for _,viewport in pairs(self._viewports) do
		viewport:update()
	end
end

function State:exit()
end

local function get_objects(self, x, y, w, h, viewport)
	local objects = {}
	local p = self._object_positions

	local x1 = math.floor(x/self._chunk_size)
	local y1 = math.floor(y/self._chunk_size)
	local x2 = math.floor((x+w)/self._chunk_size)
	local y2 = math.floor((y+h)/self._chunk_size)

	local indexes = {}

	for y = y1,y2 do
		for x = x1,x2 do
			if p[y] and p[y][x] then
				for _,object in pairs(p[y][x]) do
					if not indexes[object] then
						indexes[object] = true
	
						if viewport == self._object_viewport[object] then
							table.insert(objects, object)
						end
					end
				end
			end
		end
	end
	for k,object in pairs(self._always_draw) do
		if viewport == self._object_viewport[object]
		and not indexes[object] then
			indexes[object] = true
			table.insert(objects, object)
		end
	end

	table.sort(objects, function(a, b)
		local id1 = self._object_indexes[a]
		local id2 = self._object_indexes[b]
	
		return id1 < id2
	end)

	return objects
end

function State:getViewportObjects()
	local objects = {}

	objects.__GLOBAL = get_objects(self,0,0,GAME_WIDTH,GAME_HEIGHT)

	for _,viewport in pairs(self._viewports) do
		local x, y, scale = viewport:getPosition()
		local w, h = GAME_WIDTH/scale, GAME_HEIGHT/scale
	
		x = x-w/2
		y = y-h/2

		objects[viewport] = get_objects(self, x, y, w, h, viewport)
	end

	return objects
end

function State:draw()
	local objects = self:getViewportObjects()

	for viewport,objects in pairs(objects) do
		if viewport ~= "__GLOBAL" then -- must be an actual viewport
			viewport:push()
		end
		for _,object in pairs(objects) do
			object:draw()
		end
		if viewport ~= "__GLOBAL" then
			viewport:pop()
		end
	end
end

return State