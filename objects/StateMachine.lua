local StateMachine = class{name = "StateMachine"}
local State = require("objects.State")

function StateMachine:change(state)
	if not (state
	and state.is
	and state:is(State)) then
		return
	end

	if self.current then
		self.current:exit(state)
	end

	self.current = state
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

return StateMachine