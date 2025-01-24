-- 2 THINGS IN 1!?!?? SHOCKER

StateMachine = class{name = "StateMachine"}
State = class{name = "State"}

-- first we define State
local PHYSICS_RATE = 1/60

function State:new()
	self._objects = {}
	self._object_indexes = {}
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

function State:update(dt)
	for i,object in pairs(self._objects) do
		if object.physics then
			object:physics(dt)
		end
		if object.update then
			object:update(dt)
		end
	end
end

function State:exit()
	for i = 1, #self._objects do
		self:kill(self._objects[1])
	end
end

local function is_in_bounds(object, x,y,w,h)
	return object.x+object.width >= x
	and object.x <= x+w
	and object.y+object.height >= y
	and object.y <= y+h
end

function State:draw()
	for i, object in pairs(self._objects) do
		if object.draw then
			if object.camera then
				local x, y, scale = object.camera:getPosition()
				local w, h = GAME_WIDTH/scale, GAME_HEIGHT/scale

				x = x - w/2
				y = y - h/2

				if object.alwaysDraw or is_in_bounds(object, x,y,w,h) then
					object.camera:push()
					object:draw()
					object.camera:pop()
				end
			else
				local x, y, w, h = 0,0,GAME_WIDTH,GAME_HEIGHT
				if object.alwaysDraw or is_in_bounds(object, x,y,w,h) then
					object:draw()
				end
			end
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

	World = Slick.newWorld(GAME_WIDTH, GAME_HEIGHT)

	self.current = state(...)
	collectgarbage()
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