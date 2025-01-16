local game = {}
local map = require "assets.data.maps.test"

local function CAMERA_POS(self)
	return self.player.x+self.player.width/2, self.player.y+self.player.height/2
end

function game:enter()
	-- reinitialize world to fit world boundaries
	self.level = Level(0, 0, map)
	self.player = Player(0, 0)
	self.camera = Camera(CAMERA_POS(self))
	self.physics_lag = 0

	World:optimize()
end

function game:update(dt)
	self.physics_lag = self.physics_lag + dt

	while self.physics_lag > PHYSICS_RATE do
		self.physics_lag = self.physics_lag - PHYSICS_RATE

		self.player:physics(dt)
	end

	self.player:update(dt)
	self.camera.x, self.camera.y = CAMERA_POS(self)
end

function game:exit()
	
end

function game:draw()
	self.camera:attach(0,0,GAME_WIDTH,GAME_HEIGHT)
		self.level:draw()
		self.player:draw()
	self.camera:detach()
end

return game
