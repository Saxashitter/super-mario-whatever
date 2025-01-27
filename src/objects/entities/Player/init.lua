local Aseprite = require "src.objects.backend.Aseprite"

-- TODO: maybe merge states objects here?
NormalState = require "src.objects.entities.Player.states.Normal"
CrouchState = require "src.objects.entities.Player.states.Crouch"
SlideState = require "src.objects.entities.Player.states.Slide"

local Player = (require "src.objects.backend.Object"):extend()

local GRID_SIZE = 48
local PALETTE = love.graphics.newShader("src/shaders/paletteSwap.glsl")

function Player:new(...)
	self.animation = Aseprite("assets/images/players/mario.aseprite")
	Player.super.new(self, 10, 24, ...)

	self.gravity = 0.280
	self.runTime = 1.9
	self.dir = 1

	self:setPalette("deargodhesblack")
	self:changeState(NormalState)
end

function Player:setPalette(name)
	local paletteData = love.image.newImageData("assets/images/translations/mario_" .. name .. ".png")

	self.colors = {}
	self.convertColors = {}

	for y = 0, 63 do
		local r1, g1, b1, a1 = 0, 0, 0, 1
		local r2, g2, b2, a2 = 0, 0, 0, 1

		if y < paletteData:getHeight() then
			r1, g1, b1, a1 = paletteData:getPixel(0, y)
			r2, g2, b2, a2 = paletteData:getPixel(1, y)
		end

		self.colors[y + 1] = { r1, g1, b1, a1 }
		self.convertColors[y + 1] = { r2, g2, b2, a2 }
	end

	paletteData:release()
end

function Player:changeState(state)
	if self.state and self.state.exit then
		self.state.exit(self)
	end
	if state and state.enter then
		state.enter(self)
	end
	self.state = state
end

function Player:physics()
	if self.state and self.state.physics then
		self.state.physics(self)
	end
end

function Player:update(dt)
	if self.state and self.state.update then
		self.state.update(self, dt)
	end
	self.animation:update(dt)
end

function Player:draw()
	local rot = 0

	local ox = self.width / 2 * math.cos(rot)
	local oy = self.height * math.sin(rot)

	PALETTE:send("colors", unpack(self.colors))
	PALETTE:send("convertColors", unpack(self.convertColors))

	local shader = love.graphics.getShader()
	love.graphics.setShader(PALETTE)
	self.animation:draw(
		self.x + ox,
		self.y + self.height - oy,
		rot,
		self.dir,
		1,
		GRID_SIZE / 2,
		GRID_SIZE
	)
	love.graphics.setShader(shader)

	if DEBUG then
		Player.super.draw(self)
	end
end

return Player
