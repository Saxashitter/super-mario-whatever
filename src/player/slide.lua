local state = {}

local SLIDE_DECEL = 0.02
local STOP_SPEED = 0.2

function state:enter()
	self.animation.speed = 1
	self:resize(18, 8)
	self.animation:switch"slide"
end

function state:physics()
	self.momx = mathx.approach(self.momx, 0, SLIDE_DECEL)

	local ox = (self.width - Player.width)/2
	local oy = self.height - Player.height

	local _,len = World:queryRectangle(
		self.x + ox,
		self.y + oy,
		Player.width,
		Player.height-self.height)


	if not self:isOnGround() then
		self.momy = self.momy + GRAVITY
	end

	if self:isOnGround() then
		self.momy = math.min(self.momy, 0)
	end

	self:move()
	if self:isOnGround()
	and (math.abs(self.momx) < STOP_SPEED
	or (not Controls:down("down") and len == 0)) then
		self:resize(Player.width, Player.height)
		self:changeState(len == 0 and "normal" or "crouch")
		return
	end

	if Controls:pressed("jump")
	and len == 0 then
		self:resize(Player.width, Player.height)
		self:changeState("longjump")
		return
	end
end

function state:update(dt) end
function state:exit() end

return state