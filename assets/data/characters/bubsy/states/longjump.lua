local state = {}
local Player = require "objects.actors.Player"

local BACK_SPEED = .1
local FORWARD_SPEED = .3
local CORRECT_SPEED = .02
local FORWARD_SPEED_CAP = 6
local BACK_SPEED_CAP = 1
local AIR_DECEL = .065
local JUMP_HEIGHT = 4
local WALK_SPEED = 1.6

local WALL_WIDTH = 4
local WALL_HEIGHT = 8

function state:enter()
	self.speed = math.abs(self.momx)
	self.momx = self.momx*1.75
	self.momy = -2.8
	self.animframes = 35
	self.sprite:switch "rolling"
	self.sounds.spring:play()
end

function state:update()
	self.animframes = math.max(0, self.animframes-1)

	if self.animframes == 0
	and self.sprite.active == "rolling" then
		self.sprite:switch "longjump"
	end
end

local function is_at_wall(self)
	local y = self.y+(self.height*0.5)-(WALL_HEIGHT*0.5)
	local left = self.level:getCols(
		self.x-WALL_WIDTH,
		y,
		WALL_WIDTH,
		WALL_HEIGHT)
	local right = self.level:getCols(
		self.x+self.width,
		y,
		WALL_WIDTH,
		WALL_HEIGHT)

	if #right > 0 then
		return true, 1
	elseif #left > 0 then
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
		if math.abs(self.momx) <= self.speed then
			self.momx = mathx.approach(self.momx, self.speed*self.dir, FORWARD_SPEED)
		else
			print "guh"
			self.momx = mathx.approach(self.momx, self.speed*self.dir, CORRECT_SPEED)
		end
	elseif dir == -self.dir then
		self.momx = mathx.approach(self.momx, BACK_SPEED_CAP*dir, BACK_SPEED)
	else
		self.momx = mathx.approach(self.momx, 0, AIR_DECEL)
	end

	local gravity = GRAVITY*0.4

	if not self:isOnGround() then
		self.momy = math.min(self.momy + gravity, GRAVITY*20)
	end

	self:move()

	local wall, dir = is_at_wall(self)
	if Controls:pressed("a")
	and wall then
		local speed = math.max(WALK_SPEED*2.25, math.abs(self.momx))

		self:changeState("normal")
		self.dir = dir*-1
		self.momx = speed*self.dir
		self.momy = -JUMP_HEIGHT
		self.jumped = true
		self.sprite:switch "walljump"
		self.sounds.jump:play()
	end
end

function state:exit()
end

return state