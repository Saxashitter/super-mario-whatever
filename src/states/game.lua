GameState = class{name = "GameState", extends = State}

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
end

function GameState:new(map)
	-- reinitialize world to fit world boundaries
	local map = require("assets.data.maps."..map)
	self:super()

	self.cameraLockIn = {x = 0, y = 0, width = GAME_WIDTH, height = GAME_HEIGHT, scale = GAME_SCALE}
	self.cameraEase = 0

	self.gameCamera = Camera()
	self.gameCamera:setDeadzone(32, 48)
	self.gameCamera.scale = GAME_SCALE
	self:addViewport(self.gameCamera)

	self.hudCamera = Camera(GAME_WIDTH/2, GAME_HEIGHT/2)
	self:addViewport(self.hudCamera)

	self.level = Level(0, 0, map)
	self:add(self.level)
	self:bindObjectToViewport(self.gameCamera, self.level)
	self.level.camera = self.gameCamera

	self.gameCamera:setArea(
		self.level.x,
		self.level.y,
		self.level.width*self.level.tilewidth,
		self.level.height*self.level.tileheight)

	local player_x, player_y = 0,0
	if self.level.markers.player_pos then
		player_x = self.level.markers.player_pos[1].x-(Player.width/2)
		player_y = self.level.markers.player_pos[1].y-(Player.height)
	end

	self.player = Player(player_x, player_y)
	self:add(self.player)
	self:bindObjectToViewport(self.gameCamera, self.player)

	self.gameCamera.x = self.player.x+(self.player.width/2)
	self.gameCamera.y = self.player.y+(self.player.height/2)

	self.gameCamera.follow = self.player

	self.timer = MamoruTimer(0, 0)
	self:add(self.timer)
	self:bindObjectToViewport(self.hudCamera, self.timer)

	self.music = love.audio.newSource(
		"assets/music/"..(self.level.properties.music or "mamoru/SacredTree")..".ogg",
		"stream"
	)
	self.music:setLooping(true)
	self.music:play()

	World:optimize()
end

function GameState:update(dt)
	State.update(self, dt)
	cameraThink(self)
end