local state = {}

local SPEED = 2
local ACCEL = SPEED/10

function state:enter()
	self.jump_press = false
	self.jumped = false
end

local function handle_animation(self)
	local animName = "idle"

	if not self:isOnGround() then
		if self.animation.name ~= "jump" then
			self.animation:switch"jump"
		end

		return
	end

	if math.abs(self.momx) > 0 then
		animName = "walk"
		self.dir = mathx.sign(self.momx)
	end

	if self.animation.name ~= animName then
		self.animation:switch(animName)
	end
end

function state:physics()
	if Controls:down("jump")
	and not self.jump_press then
		self.jump_press = true
		if self:isOnGround() then
			self.jumped = true
			self.momy = -(self.height)*GRAVITY
		end
	end

	if not Controls:down("jump")
	and self.jump_press then
		self.jump_press = false

		if self.jumped
		and not self:isOnGround() then
			self.jumped = false
			if self.momy < 0 then
				self.momy = self.momy*0.5
			end
		end
	end

	local dir = 0

	if Controls:down("left") then
		dir = dir - 1
	end
	if Controls:down("right") then
		dir = dir + 1
	end

	local gravity = GRAVITY
	if self.jumped then
		gravity = gravity * 0.5
	end

	self.momx = mathx.approach(self.momx, SPEED*dir, ACCEL)
	if not self:isOnGround() then
		self.momy = self.momy + gravity
	end
	self:move()

	if self:isOnGround()
	and self.jumped then
		self.jumped = false
	end
end

function state:update(dt)
	handle_animation(self, dt)
end

return state