local Mosiac = class{
	name = "Mosiac",
	extends = require("objects.Transition")
}

local START_SCALE = GAME_SCALE*1.8
local END_SCALE = 0
local TRANS_TIME = 0.6

function Mosiac:new(transIn)
	self.transIn = (transIn)
	self.time = TRANS_TIME
	self.delay = 0.5
	self.image = makeImage("assets/images/sprites/mosiac.png")
end

function Mosiac:update(dt)
	if self.time == 0 then
		self.delay = math.max(self.delay-dt, 0)
	end
	self.time = math.max(self.time-dt, 0)
end

function Mosiac:isOver()
	return self.time == 0 and self.delay == 0
end

function Mosiac:draw()
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(0,0,0,1)

	local lerp = (TRANS_TIME-self.time)/TRANS_TIME
	if self.transIn then
		lerp = 1-lerp
	end
	local scale = mathx.lerp(END_SCALE, START_SCALE, lerp)

	love.graphics.draw(self.image,
		GAME_WIDTH/2,
		GAME_HEIGHT/2,
		0,
		scale,
		scale,
		self.image:getWidth()/2,
		self.image:getHeight()/2)

	local x = GAME_WIDTH/2
	local y = GAME_HEIGHT/2
	local width = self.image:getWidth()*scale
	local height = self.image:getHeight()*scale

	local lx = 0
	local ly = 0
	local lw = math.max(0, x - width/2)
	local lh = GAME_HEIGHT

	local ux = lw
	local uy = 0
	local uw = width
	local uh = math.max(0, y - height/2)

	local dx = lw
	local dy = y + height/2
	local dw = width
	local dh = math.max(0, GAME_HEIGHT - dy)

	local rx = x + width/2
	local ry = 0
	local rw = math.max(0, GAME_WIDTH - rx)
	local rh = GAME_HEIGHT

	love.graphics.rectangle("fill",
		lx, ly, lw, lh)
	love.graphics.rectangle("fill",
		ux, uy, uw, uh)
	love.graphics.rectangle("fill",
		dx, dy, dw, dh)
	love.graphics.rectangle("fill",
		rx, ry, rw, rh)

	love.graphics.setColor(r,g,b,a)
end

return Mosiac