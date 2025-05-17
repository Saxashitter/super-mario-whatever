local state = {}
local Player = require "objects.actors.Player"

local SLIDE_DECEL = 0.02
local STOP_SPEED = 0.2

function state:enter()
	self.sprite.speed = 1
	self:resize(18, 8)
	self.sprite:switch"slide"
end

function state:physics()
	self.momx = mathx.approach(self.momx, 0, SLIDE_DECEL)

	local ox = (self.width - Player.width)/2
	local oy = self.height - Player.height

	if not self:isOnGround() then
		self.momy = self.momy + GRAVITY
	end


	self:move()
	local cols = self.world:search(
		self.x + ox,
		self.y + oy,
		Player.width,
		Player.height-self.height)

	if self:isOnGround()
	and (math.abs(self.momx) < STOP_SPEED
	or (not self.controls.down and #cols == 0)) then
		self:resize(Player.width, Player.height)
		self:changeState(#cols == 0 and "normal" or "crouch")
		return
	end

	if self.controls.a_press then
		self:resize(Player.width, Player.height)
		self:changeState("longjump")
		return
	end
end

function state:update(dt) end
function state:exit() end

return state