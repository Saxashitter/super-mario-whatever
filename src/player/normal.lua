local state = {}

local WALKSPEED = 1.9 -- 01900
local MINWALKSPEED = .130 -- 00130
local WALKACCEL = .098 -- 00098
local RUNACCEL = .050 -- 000E4 (this is not right at all)
local SKIDDECEL = .24 -- 001A0
local DECEL = .14 -- 000D0
local JUMPHEIGHT = 4

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
			self.momy = -JUMPHEIGHT
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

	local dir = 0
	local movedir =  mathx.sign(self.momx)

	if Controls:down("left") then
		dir = dir - 1
	end
	if Controls:down("right") then
		dir = dir + 1
	end

	if movedir == 0 then
		if dir ~= 0
		and self.momx*movedir < MINWALKSPEED then
			self.momx = MINWALKSPEED*dir
		end
	else
		local accel = WALKACCEL

		if dir == 0 then
			accel = DECEL
		elseif dir == -movedir then
			accel = SKIDDECEL
		end
		
		self.momx = mathx.approach(self.momx, WALKSPEED*dir, accel)
	end

	local gravity = GRAVITY
	if self.jumped
	and self.momy < 0 then
		gravity = gravity * 0.5
	end

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