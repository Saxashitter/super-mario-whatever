local state = {}
local Player = require "objects.actors.Player"

local JUMP_HEIGHT = 4
local AIR_ACCEL = .1
local CROUCH_DECEL = 0.08
local AIR_SKID_DECEL = .15
local MAX_SPEED = 1.3

function state:enter()
	self.animation:switch "crouch"
	self.animation.speed = 1
	self.runTime = 0
	self:resize(10, 12)
end

function state:update(dt)
end

function state:physics()
	if Controls:pressed("jump") then
		if self:isOnGround() then
			local height = JUMP_HEIGHT

			self.jumped = true
			self.momy = -height
		end
	end

	if not Controls:down("jump") then
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

	if self:isOnGround() then
		self.momx = mathx.approach(self.momx, 0, CROUCH_DECEL)
	end

	if not self:isOnGround() then
		local accel = AIR_ACCEL
		local speed = MAX_SPEED

		if dir == -movedir then
			accel = AIR_SKID_DECEL
		end

		self.momx = mathx.approach(self.momx, speed*dir, accel)
	end

	if dir ~= 0 then
		self.dir = dir
	end

	local gravity = GRAVITY

	if self.jumped
	and self.momy < 0 then
		gravity = gravity * 0.5
	end

	if not self:isOnGround() then
		self.momy = math.min(self.momy + gravity, gravity*20)
	end
	if self:isWallBlocking(self.momx) then
		self.momx = 0
	end

	self:move()

	if self:isOnGround()
	and self.jumped then
		self.jumped = false
	end

	local ox = (self.width - Player.width)/2
	local oy = self.height - Player.height

	local _,len = World:queryRectangle(
		self.x + ox,
		self.y + oy,
		Player.width,
		Player.height-self.height)

	if not Controls:down("down")
	and self:isOnGround()
	and len == 0 then
		self:resize(Player.width, Player.height)
		self:changeState("normal")
		return
	end
end

function state:exit()
end

return state