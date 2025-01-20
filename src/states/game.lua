GameState = class{name = "GameState", extends = State}

local map = require "assets.data.maps.test"

local function CAMERA_POS(self)
	local width, height = self.player.width/2, self.player.height/2
	local x, y = self.player.x, self.player.y

	x = x + width
	y = y + height

	local scale = GAME_SCALE

	local cam = self.level:isInCamera(self.player)
	local inCam = false
	if cam then
		if self.cameraLockIn ~= cam then
			self.cameraEase = 0
		end

		self.cameraLockIn = cam
		inCam = true
	end

	local cam = self.cameraLockIn

	local cs = math.max(GAME_WIDTH / cam.width, GAME_HEIGHT / cam.height)
	local gw, gh = GAME_WIDTH / cs, GAME_HEIGHT / cs
	local cx = math.max(cam.x+(gw/2), math.min(x, cam.x+cam.width-(gw/2)))
	local cy = math.max(cam.y+(gh/2), math.min(y, cam.y+cam.height-(gh/2)))

	if inCam then
		self.cameraEase = mathx.lerp(self.cameraEase, 1, 0.1)
	else
		self.cameraEase = mathx.lerp(self.cameraEase, 0, 0.1)
	end

	local changeX = cx - x
	local changeY = cy - y
	local changeS = cs - scale

	return Ease.linear(self.cameraEase, x, changeX, 1),
		Ease.linear(self.cameraEase, y, changeY, 1),
		Ease.linear(self.cameraEase, scale, changeS, 1)
end

function GameState:new()
	-- reinitialize world to fit world boundaries
	self:super()

	self.cameraLockIn = {x = 0, y = 0, width = GAME_WIDTH, height = GAME_HEIGHT, scale = GAME_SCALE}
	self.cameraEase = 0

	self.gameCamera = Camera()
	self.gameCamera.scale = GAME_SCALE

	self.hudCamera = Camera()
	self.hudCamera.scale = GAME_SCALE

	self.level = Level(0, 0, map)
	self.level.camera = self.gameCamera
	self:add(self.level)

	self.player = Player(0, 0)
	self.player.camera = self.gameCamera
	self:add(self.player)

	self.gameCamera.x, self.gameCamera.y, self.gameCamera.scale = CAMERA_POS(self)

	World:optimize()
end

function GameState:update(dt)
	State.update(self, dt)

	self.gameCamera.x, self.gameCamera.y, self.gameCamera.scale = CAMERA_POS(self)
end