local Controls = require "src.objects.backend.Controls"

local State = {}

local JUMP_HEIGHT = 4
local CROUCH_DECEL = 0.5

function State:enter()
	self.animation:switch "crouch"
	self.animation.speed = 1
	self.runTime = 0
	self:resize(16, 12)
end

function State:physics()
	if not Controls:down("down") then
		self:resize(10, 24)
		self:changeState(NormalState)
	end
	if Controls:down("jump")
		and not self.jumpPress then
		self.jumpPress = true

		if self:isOnGround() then
			local height = JUMP_HEIGHT

			self.jumped = true
			self.momy = -height
		end
	end

	if not Controls:down("jump")
		and self.jumpPress then
		self.jumpPress = false

		if self.jumped
			and not self:isOnGround() then
			self.jumped = false
		end
	end

	if self:isOnGround() then
		self.momx = math.approach(self.momx, 0, CROUCH_DECEL)
	end

	local gravity = self.gravity

	if self.jumped
		and self.momy < 0 then
		gravity = gravity * 0.5
	end

	if not self:isOnGround() then
		self.momy = math.min(self.momy + gravity, gravity * 20)
	end

	if self:isOnGround() then
		self.momy = math.min(self.momy, 0)
	end

	self:move()

	if self:isOnGround()
		and self.jumped then
		self.jumped = false
	end
end

return State
