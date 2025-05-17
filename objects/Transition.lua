local Transition = class{name = "Transition"}

function Transition:new(transIn)
	self.transIn = (transIn)
end

function Transition:isOver()
	return true
end

function Transition:update()
end

function Transition:draw()
end

return Transition