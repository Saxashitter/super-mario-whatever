local Animation = require "objects.Animation"

local MamoruTimer = class{name = "MamoruTimer"}

MamoruTimer.width = 128
MamoruTimer.height = 128
MamoruTimer.maxFlames = 6

local FLAME_WIDTH = 128/8
local FLAME_HEIGHT = 64/2

function MamoruTimer:new(x, y)
	self.x = x or 0
	self.y = y or 0

	self.image = makeImage("assets/images/ui/timer/time.png")
	self.flame = Animation(
		love.graphics.newImage("assets/images/ui/timer/flame.png"),
		FLAME_WIDTH,
		FLAME_HEIGHT,
		{
			default = "flame",
			{
				name = "flame",
				frames = {
					{0,0},{0,1},{0,2},{0,3},
					{0,4},{0,5},{0,6},{0,7},
					{1,0},{1,1},{1,2},{1,3},
					{1,4},{1,5},{1,6},{1,7}
				},
				fps = 20
			}
		}
	)
end

function MamoruTimer:update(dt)
	self.flame:update(dt)
end

function MamoruTimer:draw(time, left)
	local scale = 1.5

	love.graphics.draw(self.image, self.x, self.y, 0, scale, scale)

	local x = self.x+self.width*scale/2
	local y = self.y+10+self.height*scale/2
	local offset = 38

	for i = 1,self.maxFlames do
		local angle = (math.pi * 2 / self.maxFlames) * (i-1)
		local ox = offset*math.sin(angle)*scale
		local oy = -offset*math.cos(angle)*scale
		self.flame:draw(
			x+ox, y+oy,
			0,
			scale,
			scale,
			FLAME_WIDTH/2,
			FLAME_HEIGHT
		)
	end
end

return MamoruTimer