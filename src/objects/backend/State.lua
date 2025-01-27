local State = Class:extend()

local PHYSICS_RATE = 1 / 60

State.interpolation = true

function State:enter()
	self._objects = {}
	self._object_indexes = {}
	self._physics_time = 0
end

function State:kill(object)
	if self._object_indexes[object] == nil then
		return
	end

	table.remove(self._objects, self._object_indexes[object])
	self._object_indexes[object] = nil
end

function State:add(object)
	if object == nil then
		error "bro..."
	end
	if self._object_indexes[object] then
		return
	end

	table.insert(self._objects, object)
	self._object_indexes[object] = #self._objects
end

function State:getInterpolationPosition(object)
	if not self.interpolation then
		return object.x, object.y
	end

	local lerp = math.min(self._physics_time / PHYSICS_RATE, 1)

	local x, y = object.x, object.y
	local tx, ty = object.x + object.momx, object.y + object.momy

	return mathx.lerp(x, tx, lerp), mathx.lerp(y, ty, lerp)
end

function State:update(dt)
	self._physics_time = self._physics_time + dt

	for i, object in pairs(self._objects) do
		if object.update then
			object:update(dt)
		end
	end
	while self._physics_time >= PHYSICS_RATE do
		for i, object in pairs(self._objects) do
			if object.physics then
				object:physics(dt)
			end
		end
		self._physics_time = self._physics_time - PHYSICS_RATE
	end
end

function State:draw()
	for i, object in pairs(self._objects) do
		if object.draw then
			if object.camera then
				object.camera:start()
				object:draw()
				object.camera:finish()
			else
				object:draw()
			end
		end
	end
end

function State:exit()
	for i = 1, #self._objects do
		self:kill(self._objects[1])
	end
end

return State
