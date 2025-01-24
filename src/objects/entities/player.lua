Player = class({
	name = "Player",
	extends = GameObject
})
Player.states = {
	normal = require "src.player.normal",
	slide = require "src.player.slide",
	crouch = require "src.player.crouch",
}
Player.state = Player.states.normal
Player.width = 10
Player.height = 24
Player.character = "mario"
Player.runTime = 1.9

local palette = love.graphics.newShader("src/shaders/paletteSwap.glsl")

local GRID_SIZE = 48

function Player:new(x, y)
	self.animation = Aseprite("assets/images/aseprite/mario.aseprite")
	self:setPalette("deargodhesblack")
	self:super(x, y)

	self.runTime = 0
	self.dir = 1

	if self.state
	and self.state.enter then
		self.state.enter(self)
	end
end

function Player:setPalette(name)
	local paletteData = love.image.newImageData("assets/images/translations/mario_"..name..".png")

	self.colors = {}
	self.convertColors = {}

	for y = 0,63 do
		local r1,g1,b1,a1 = 0,0,0,1
		local r2,g2,b2,a2 = 0,0,0,1

		if y < paletteData:getHeight() then
			r1,g1,b1,a1 = paletteData:getPixel(0, y)
			r2,g2,b2,a2 = paletteData:getPixel(1, y)
		end

		self.colors[y+1] = {r1,g1,b1,a1}
		self.convertColors[y+1] = {r2,g2,b2,a2}
	end
end

function Player:changeState(name)
	if not self.states[name] then
		return
	end

	if self.state
	and self.state.exit then
		self.state.exit(self)
	end

	self.state = self.states[name]

	if self.state.enter then
		self.state.enter(self)
	end
end

function Player:physics()
	if self.state
	and self.state.physics then
		self.state.physics(self)
	end
end

function Player:update(dt)
	if self.state
	and self.state.update then
		self.state.update(self, dt)
	end

	self.animation:update(dt)
end

function Player:draw()
	local rot = 0

	local ox = self.width/2*math.cos(rot)
	local oy = self.height*math.sin(rot)

	palette:send("colors", unpack(self.colors))
	palette:send("convertColors", unpack(self.convertColors))

	love.graphics.setShader(palette)
		self.animation:draw(
			self.x + ox,
			self.y + self.height - oy,
			rot,
			self.dir,
			1,
			GRID_SIZE/2,
			GRID_SIZE
		)
	love.graphics.setShader()

	if DEBUG then
		GameObject.draw(self)
	end
end