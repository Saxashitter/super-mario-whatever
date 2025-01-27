local Controls = require "src.objects.backend.Controls"

local State = {}

local SLIDE_DECEL = 0.02
local STOP_SPEED = 0.2

function State:enter()
	self.animation.speed = 1
	self:resize(24, 8)
	self.animation:switch "slide"
end

function State:physics()
	self.momx = math.approach(self.momx, 0, SLIDE_DECEL)

	if math.abs(self.momx) < STOP_SPEED
		or not Controls:down("down") then
		self:resize(10, 24)
		self:changeState(NormalState)
		return
	end

	if not self:isOnGround() then
		self.momy = self.momy + self.gravity
	end

	if self:isOnGround() then
		self.momy = math.min(self.momy, 0)
	end

	self:move()
end

return State
