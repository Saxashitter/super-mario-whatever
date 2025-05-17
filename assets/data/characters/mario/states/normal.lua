local state = {}
local Player = require "objects.actors.Player"

local WALK_ACCEL = .17
local RUN_ACCEL = .2
local AIR_ACCEL = .1

local DECEL = .09
local SKID_DECEL = .32
local AIR_DECEL = .065
local AIR_SKID_DECEL = .15

local JUMP_FRAMES = 7
local TWIRL_FRAMES = 8
local TWIRLCOOLDOWN_FRAMES = TWIRL_FRAMES+17

local JUMP_GRAVITY = GRAVITY*0.5

local JUMP_HEIGHT = 4
local JUMP2_HEIGHT = 4.75
local JUMP3_HEIGHT = 5.3

local WALK_SPEED = 1.6
local MIN_WALK_SPEED = .8
local RUN_SPEED = 3.4
local MAX_RUN_SPEED = 4.2
local TJ_SPEED = 2

function state:enter()
	self.jump_press = false
	self.jumped = false
	self.jumps = 1
	self.jumpframes = 0
	self.crouch = false
	self.twirlframes = 0
	self.twirlcooldown = 0
end

local function handle_animation(self)
	local animName = "idle"
	local active = self.sprite.active

	if not self:isOnGround() then
		self.sprite.speed = 1
		if self.crouched then
			if active ~= "crouch" then
				self.sprite:switch "crouch"
			end
			return
		end


		if (active == "jump1"
		or active == "jump2"
		or active == "jump3")
		and self.momy >= 0 then
			self.sprite:switch "fall"
		end

		return
	end

	if self.crouched then
		animName = "crouch"
		self.sprite.speed = 1
	elseif math.abs(self.momx) > 0 then
		animName = "walk"
		self.sprite.speed = (math.abs(self.momx) / WALK_SPEED) / 1.25
		self.dir = mathx.sign(self.momx)
	else
		self.sprite.speed = 1
		if self.controls.up then
			animName = "lookup"
		end
	end

	if math.abs(self.momx) > RUN_SPEED then
		animName = "run"
	end

	if self.sprite.active ~= animName then
		self.sprite:switch(animName)
	end
end

function state:physics()
	if self.controls.a_press then
		local wall, dir = self:isAtWall(self)

		if self:isOnGround() then
			local height = JUMP_HEIGHT
			local sound = self.sounds.jump

			if self.jumps == 2 then
				height = JUMP2_HEIGHT
				sound = self.sounds.spin
			elseif self.jumps == 3 then
				if math.abs(self.momx) >= TJ_SPEED then
					height = JUMP3_HEIGHT
					sound = self.sounds.spring
				else
					self.jumps = 1
				end
			end

			self.jumped = true
			self.momy = -height
	
			self.sprite:switch("jump"..self.jumps)

			self.jumpframes = 0
			self.jumps = self.jumps+1
			if self.jumps > 3 then
				self.jumps = 1
			else
				self.jumpframes = JUMP_FRAMES
			end
			sound:play()
		elseif wall then
			local speed = math.max(WALK_SPEED*2.25, math.abs(self.momx))

			self.dir = dir*-1
			self.momx = speed*self.dir
			self.momy = -JUMP_HEIGHT
			self.jumped = true
			self.twirlcooldown = 45
			self.sprite:switch "walljump"
			self.sounds.jump:play()
		elseif self.twirlframes == 0
		and self.twirlcooldown == 0 then
			self.twirlframes = TWIRL_FRAMES
			self.twirlcooldown = TWIRLCOOLDOWN_FRAMES
			self.momy = 0
			self.sounds.spin:play()
		end
	end

	if not self.controls.a then
		if self.jumped
		and not self:isOnGround() then
			self.jumped = false
		end
	end

	local dir = 0
	local movedir =  mathx.sign(self.momx)

	if self.controls.left then
		dir = dir - 1
	end
	if self.controls.right then
		dir = dir + 1
	end

	if movedir == 0 then
		if dir ~= 0
		and self.momx*movedir < MIN_WALK_SPEED then
			self.momx = MIN_WALK_SPEED*dir
		end
	else
		local accel = WALK_ACCEL
		local speed = WALK_SPEED

		if self.controls.x then
			speed = RUN_SPEED
			accel = RUN_ACCEL

			if self.runTime == Player.runTime then
				speed = MAX_RUN_SPEED
			end
		end

		if not self:isOnGround() then
			accel = AIR_ACCEL
		end

		if dir == 0 then
			if self:isOnGround() then
				accel = DECEL
			else
				accel = AIR_DECEL
			end
		end
		if dir == -movedir then
			if self:isOnGround() then
				accel = SKID_DECEL
			else
				accel = AIR_SKID_DECEL
			end
		end
		
		self.momx = mathx.approach(self.momx, speed*dir, accel)
	end

	if math.abs(self.momx) > WALK_SPEED
	and self.controls.x
	and self:isOnGround() then
		self.runTime = math.min(self.runTime + (1/60), Player.runTime)
	else
		if self:isOnGround()
		or not self.controls.x then
			self.runTime = 0
		end
	end

	self.twirlframes = math.max(0, self.twirlframes-1)
	self.twirlcooldown = math.max(0, self.twirlcooldown-1)

	local gravity = GRAVITY
	if self.jumped
	and self.momy < 0 then
		gravity = JUMP_GRAVITY
	end

	if not self:isOnGround()
	and self.twirlframes == 0 then
		self.momy = math.min(self.momy + gravity, gravity*20)
	end

	self:move()

	if self:isOnGround()
	and self.jumped then
		self.jumped = false
	end

	if self.controls.down
	and self:isOnGround() then
		local state = "crouch"
		if math.abs(self.momx) > WALK_SPEED then
			state = "slide"
		end

		self:changeState(state)
	end

	if self:isOnGround() then
		self.twirlframes = 0
		self.twirlcooldown = 0
		self.jumpframes = math.max(0, self.jumpframes-1)
		if self.jumpframes == 0 then
			self.jumps = 1
		end
	end
end

function state:update(dt)
	handle_animation(self, dt)
end

return state