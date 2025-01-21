local state = {}

local WALK_SPEED = 1.6
local MIN_WALK_SPEED = .8
local RUN_SPEED = 3.4
local MAX_RUN_SPEED = 4.2
local WALK_ACCEL = .17
local RUN_ACCEL = .23
local SKID_DECEL = .32
local DECEL = .09
local JUMP_HEIGHT = 4
local AIR_SKID_DECEL = .15

local WALL_WIDTH = 4
local WALL_HEIGHT = 5

function state:enter()
	self.jump_press = false
	self.jumped = false
end

local function handle_animation(self)
	local animName = "idle"

	if not self:isOnGround() then
		self.animation.speed = 1
		if self.animation.name ~= "jump"
		and self.animation.name ~= "walljump" then
			self.animation:switch"jump"
		end

		return
	end

	if math.abs(self.momx) > 0 then
		animName = "walk"
		self.animation.speed = math.abs(self.momx) / WALK_SPEED
		self.dir = mathx.sign(self.momx)
	else
		self.animation.speed = 1
	end

	if math.abs(self.momx) > RUN_SPEED then
		animName = "run"
	end

	if self.animation.name ~= animName then
		self.animation:switch(animName)
	end
end

local function is_collision_sloped(response)
	return math.abs(response.normal.y) <= 0.5
end

local function is_at_wall(self)
	local y = self.y+(self.height*0.5)-(WALL_HEIGHT*0.5)
	local left = {World:queryRectangle(
		self.x-WALL_WIDTH,
		y,
		WALL_WIDTH,
		WALL_HEIGHT)}
	local right = {World:queryRectangle(
		self.x+self.width,
		y,
		WALL_WIDTH,
		WALL_HEIGHT)}

	if right[2] > 0 then
		return true, 1
	elseif left[2] > 0 then
		return true, -1
	end

	return false, 0
end

function state:physics()
	if Controls:down("jump")
	and not self.jump_press then
		self.jump_press = true

		local wall, dir = is_at_wall(self)

		if self:isOnGround() then
			self.jumped = true
			self.momy = -JUMP_HEIGHT
		elseif wall then
			local speed = math.max(WALK_SPEED*2.25, math.abs(self.momx))

			self.dir = dir*-1
			self.momx = speed*self.dir
			self.momy = -JUMP_HEIGHT
			self.jumped = true
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

	if Controls:down("down")
	and self.momx > WALK_SPEED then
		self:changeState("slide")
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
		and self.momx*movedir < MIN_WALK_SPEED then
			self.momx = MIN_WALK_SPEED*dir
		end
	else
		local accel = WALK_ACCEL
		local speed = WALK_SPEED

		if dir == 0 then
			accel = DECEL
		elseif dir == -movedir
		and self:isOnGround() then
			accel = SKID_DECEL
		elseif dir == -movedir
		and not self:isOnGround() then
			accel = AIR_SKID_DECEL
		end

		if Controls:down("run") then
			speed = RUN_SPEED
			if dir == movedir then
				accel = RUN_ACCEL
			end

			if self.runTime == Player.runTime then
				speed = MAX_RUN_SPEED
			end
		end
		
		self.momx = mathx.approach(self.momx, speed*dir, accel)
	end

	if math.abs(self.momx) > WALK_SPEED
	and Controls:down("run")
	and self:isOnGround() then
		self.runTime = math.min(self.runTime + (1/60), Player.runTime)
	else
		if self:isOnGround()
		or not Controls:down("run") then
			self.runTime = 0
		end
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

function state:update(dt)
	handle_animation(self, dt)
end

return state