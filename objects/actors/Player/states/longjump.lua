local state = {}
local Player = require "objects.actors.Player"

local FORWARD_SPEED = .13
local BACK_SPEED = .1
local FORWARD_SPEED_CAP = 6
local BACK_SPEED_CAP = 1
local AIR_DECEL = .065
local JUMP_HEIGHT = 4
local WALK_SPEED = 1.6

local WALL_WIDTH = 4
local WALL_HEIGHT = 5

function state:enter()
	self.speed = math.abs(self.momx)
	self.momx = self.momx*1.5
	if math.abs(self.momx) > FORWARD_SPEED_CAP then
		self.momx = FORWARD_SPEED_CAP*self.dir
	end
	self.momy = -2.8
	self.animframes = 35
	self.animation:switch "rolling"
end

function state:update()
	self.animframes = math.max(0, self.animframes-1)

	if self.animframes == 0
	and self.animation.active == "rolling" then
		self.animation:switch "longjump"
	end
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
	if self:isOnGround() then
		self:changeState("normal")
		return
	end

	local dir = 0
	if Controls:down("right") then
		dir = dir + 1
	end
	if Controls:down("left") then
		dir = dir - 1
	end

	if dir == self.dir then
		if math.abs(self.momx) < FORWARD_SPEED then
			self.momx = mathx.approach(self.momx, FORWARD_SPEED_CAP*self.dir, FORWARD_SPEED)
		end
	elseif dir == -self.dir then
		self.momx = mathx.approach(self.momx, BACK_SPEED_CAP*dir, BACK_SPEED)
	else
		self.momx = mathx.approach(self.momx, 0, AIR_DECEL)
	end

	local gravity = GRAVITY*0.4

	if not self:isOnGround() then
		self.momy = math.min(self.momy + gravity, gravity*20)
	end

	self:move()

	local wall, dir = is_at_wall(self)
	if Controls:pressed("jump")
	and wall then
		local speed = math.max(WALK_SPEED*2.25, math.abs(self.momx))

		self:changeState("normal")
		self.dir = dir*-1
		self.momx = speed*self.dir
		self.momy = -JUMP_HEIGHT
		self.jumped = true
		self.animation:switch "walljump"
	end
end

function state:exit()
end

return state