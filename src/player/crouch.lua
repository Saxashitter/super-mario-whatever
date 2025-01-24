local state = {}

local JUMP_HEIGHT = 4
local CROUCH_DECEL = 0.5

function state:enter()
	self.animation:switch "crouch"
	self.animation.speed = 1
	self.runTime = 0
	self:resize(16, 12)
end

function state:update(dt)
end

function state:physics()
	if not Controls:down("down") then
		self:resize(Player.width, Player.height)
		self:changeState("normal")
	end
	if Controls:down("jump")
	and not self.jump_press then
		self.jump_press = true

		if self:isOnGround() then
			local height = JUMP_HEIGHT

			self.jumped = true
			self.momy = -height
		end
	end

	if not Controls:down("jump")
	and self.jump_press then
		self.jump_press = false

		if self.jumped
		and not self:isOnGround() then
			self.jumped = false
		end
	end

	if self:isOnGround() then
		self.momx = mathx.approach(self.momx, 0, CROUCH_DECEL)
	end

	local gravity = GRAVITY

	if self.jumped
	and self.momy < 0 then
		gravity = gravity * 0.5
	end

	if not self:isOnGround() then
		self.momy = math.min(self.momy + gravity, gravity*20)
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

function state:exit()
end

return state