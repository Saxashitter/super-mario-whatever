local state = {}

local SLIDE_DECEL = 0.02
local STOP_SPEED = 0.2

function state:enter()
	self.animation.speed = 1
	self:resize(24, 8)
	self.animation:switch"slide"
end

function state:physics()
	self.momx = mathx.approach(self.momx, 0, SLIDE_DECEL)
	print "slide"

	if math.abs(self.momx) < STOP_SPEED then
		self:resize(Player.width, Player.height)
		self:changeState("normal")
		return
	end

	if not self:isOnGround() then
		self.momy = self.momy + GRAVITY
	end

	if self:isOnGround() then
		self.momy = math.min(self.momy, 0)
	end

	self:move()
end

function state:update(dt) end
function state:exit() end

return state