GameState = class{name = "GameState", extends = State}

local map = require "assets.data.maps.test"

local function cameraThink(self)
	local x_speed = 4
	local x_offset = 0

	if math.abs(self.player.momx) > 3.4 then
		x_speed = 2
		x_offset = 100*mathx.sign(self.player.momx)
	end

	self.gameCamera.offset.x = mathx.approach(self.gameCamera.offset.x, x_offset, x_speed)

	if self.player:isOnGround() then
		self.gameCamera.y = mathx.approach(self.gameCamera.y, self.player.y+(self.player.height/2), 1)
	end
	if self.player.momx == 0 then
		self.gameCamera.x = mathx.approach(self.gameCamera.x, self.player.x+(self.player.width/2), 1)
	end
end

function GameState:new()
	-- reinitialize world to fit world boundaries
	self:super()

	self.cameraLockIn = {x = 0, y = 0, width = GAME_WIDTH, height = GAME_HEIGHT, scale = GAME_SCALE}
	self.cameraEase = 0

	self.gameCamera = Camera()
	self.gameCamera:setDeadzone(32, 48)
	self.gameCamera.scale = GAME_SCALE

	self.hudCamera = Camera(GAME_WIDTH/2, GAME_HEIGHT/2)

	self.level = Level(0, 0, map)
	self.level.camera = self.gameCamera
	for k,v in pairs(self.level.objects) do
		v.camera = self.gameCamera
		self:add(v)
	end
	self:add(self.level)

	self.player = Player(0, 0)
	self.player.camera = self.gameCamera
	self:add(self.player)

	self.gameCamera.follow = self.player
	self:add(self.gameCamera)

	self.timer = MamoruTimer(0, 128)
	self:add(self.timer)

	World:optimize()
end

function GameState:update(dt)
	State.update(self, dt)
	cameraThink(self)
end