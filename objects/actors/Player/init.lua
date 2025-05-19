local _PATH = (...)
local GameObject = require "objects.GameObject"
local Aseprite = require "objects.animation.Aseprite"
local Player = class({
	name = "Player",
	extends = GameObject
})

local palette = love.graphics.newShader("shaders/paletteSwap.glsl")

Player.width = 10
Player.height = 24
Player.character = "mario"
Player.runTime = 1.9

function Player:new(x, y, character, world)
	if not character then
		character = require("assets.data.characters.meta")[1]
	end

	local path = character.path

	self.characterMeta = character
	self.character = require("assets.data.characters."..path)

	self.sprite = Aseprite("assets/data/characters/"..path.."/sheet.aseprite")
	self.scale = 1
	self:setPalette("black")
	
	self.coins = 0
	self.dir = 1
	self.controls = {}
	self:super(x, y, world)

	if self.character.load then
		self.character.load(self)
	end
end

function Player:handleInputs()
	local controls = {}

	controls.left = Controls:down("left")
	controls.down = Controls:down("down")
	controls.up = Controls:down("up")
	controls.right = Controls:down("right")
	controls.a = Controls:down("a")
	controls.b = Controls:down("b")
	controls.x = Controls:down("x")
	controls.y = Controls:down("y")
	controls.a_press = controls.a and not (self.controls and self.controls.a)

	self.controls = controls
end

function Player:setPalette(name)
	local paletteData = love.image.newImageData("assets/data/characters/"..self.characterMeta.path.."/palettes/"..name..".png")

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

function Player:physics()
	self:handleInputs()

	if self.character.physics then
		self.character.physics(self)
	end
end

function Player:update(dt)
	if self.character.update then
		self.character.update(self, dt)
	end

	self.sprite:update(dt)
end

function Player:draw()
	local rot = 0

	local ox = self.width/2*math.cos(rot)
	local oy = self.height*math.sin(rot)

	palette:send("colors", unpack(self.colors))
	palette:send("convertColors", unpack(self.convertColors))

	love.graphics.setShader(palette)
	self.sprite:draw(
		self.x + ox,
		self.y + self.height - oy,
		rot,
		self.dir*self.scale,
		self.scale,
		self.sprite.width/2,
		self.sprite.height
	)
	love.graphics.setShader()

	if DEBUG then
		GameObject.draw(self)
	end
end

function Player:getSync()
	local sync = GameObject.sync(self)

	sync.animation = {}
	sync.animation.active = self.animation.active
	sync.animation.index = self.animation.index

	return sync
end

return Player