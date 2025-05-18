local state = {}
local Player = require "objects.actors.Player"

local JUMP_HEIGHT = 4
local AIR_ACCEL = .1
local CROUCH_DECEL = 0.08
local AIR_SKID_DECEL = .15
local MAX_SPEED = 1.3

function state:enter()
	self.sprite:switch "crouch"
	self.sprite.speed = 1
	self.runTime = 0
	self:resize(Player.width, 12)
end

function state:update(dt)
end

function state:physics()
	if self.controls.a_press then
		if self:isOnGround() then
			local height = JUMP_HEIGHT

			self.jumped = true
			self.momy = -height
			self.sounds.jump:play()
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

	self:move()

	if self:isOnGround()
	and self.jumped then
		self.jumped = false
	end

	local ox = (self.width - Player.width)/2
	local oy = self.height - Player.height

	local cols = self.world:search(
		self.x + ox,
		self.y + oy,
		Player.width,
		Player.height-self.height)

	if not self.controls.down
	and self:isOnGround()
	and #cols == 0 then
		self:resize(Player.width, Player.height)
		self:changeState("normal")
		return
	end
end

function state:exit()
end

return state