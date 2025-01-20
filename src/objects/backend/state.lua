-- 2 THINGS IN 1!?!?? SHOCKER

StateMachine = class{name = "StateMachine"}
State = class{name = "State"}

-- first we define State
local PHYSICS_RATE = 1/60

State.interpolation = true

function State:new()
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
	if self._object_indexes[object] then
		return
	end

	table.insert(self._objects, object)
	self._object_indexes[object] = #self._objects
	print("added "..object:type())
end

function State:update(dt)
	self._physics_time = self._physics_time + dt

	for i,object in pairs(self._objects) do
		object:update(dt)
	end
	while self._physics_time >= PHYSICS_RATE do
		for i,object in pairs(self._objects) do
			object:physics(dt)
		end
		self._physics_time = self._physics_time - PHYSICS_RATE
	end
end

function State:getInterpolationPosition(object)
	if not self.interpolation then
		return object.x, object.y
	end

	local lerp = math.min(self._physics_time / PHYSICS_RATE, 1)

	local x, y = object.x, object.y
	local tx, ty = object.x+object.momx, object.y+object.momy

	return mathx.lerp(x, tx, lerp), mathx.lerp(y, ty, lerp)
end

function State:exit()
	for i = 1, #self._objects do
		self:kill(self._objects[1])
	end
end

function State:draw()
	for i, object in pairs(self._objects) do
		if object.camera then
			object.camera:attach(0,0, GAME_WIDTH, GAME_HEIGHT)
		end

		object:draw()

		if object.camera then
			object.camera:detach()
		end
	end
end

-- and now we define StateMachine

function StateMachine:change(state, ...)
	if not (state
	and state.is
	and state:is(State)) then
		return
	end

	if self.current then
		self.current:exit(state)
	end

	self.current = state(...)
end

function StateMachine:new(initialState)
	if initialState
	and initialState.is
	and initialState:is(State) then
		self:change(initialState)
	end
end

function StateMachine:update(dt)
	if not self.current then return end

	self.current:update(dt)
end

function StateMachine:draw()
	if not self.current then return end

	self.current:draw()
end

function StateMachine:call(value, ...)
	if not self.current then return end
	if not self.current[value] then return end

	return self.current[value](self, ...)
end