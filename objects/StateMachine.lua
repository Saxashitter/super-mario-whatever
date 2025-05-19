local StateMachine = class{name = "StateMachine"}
local State = require("objects.State")

local function change(self, state, transition)
	if not (state
	and state.is
	and state:is(State)) then
		return
	end

	if self.current then
		self.current:exit(state)
	end
	state:enter(self.current)
	self.current = nil

	clearCache()

	self.current = state
	self.transition = transition and transition(false)
end

function StateMachine:change(state, transitionIn, transitionOut)
	if transitionIn then
		self._state = state
		self._transitionOut = transitionOut
		self.transitionIn = transitionIn(true)
		return
	end

	change(self, state, transitionOut)
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

	if self.transitionIn then
		if self.transitionIn:isOver() then
			change(self, self._state, self._transitionOut)
			self._state = nil
			self._transitionOut = nil
			self.transitionIn = nil
		else
			self.transitionIn:update(dt)
		end
		return
	end

	self.current:update(dt)

	if self.transition then
		if self.transition:isOver() then
			self.transition = nil
		else
			self.transition:update(dt)
		end
	end
end

function StateMachine:draw()
	if not self.current then return end

	self.current:draw()
	if self.transitionIn then
		self.transitionIn:draw()
	end
	if self.transition then
		self.transition:draw()
	end
end

function StateMachine:call(value, ...)
	if not self.current then return end
	if not self.current[value] then return end

	return self.current[value](self, ...)
end

return StateMachine