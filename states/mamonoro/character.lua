local Characters = require("assets.data.characters.meta")
local Sprite = require("objects.Sprite")
local Menu = require("objects.Menu")
local GameState = require("states.game")
local Mosiac = require "objects.transitions.Mosiac"
local State = class{
	name = "CharacterSelect",
	extends = require("objects.State")
}

local absoluteColor = love.graphics.newShader("shaders/absoluteColor.glsl")

local UNSELECTED_X = GAME_WIDTH
local HEIGHT = 500

local CHARACTER_TWEEN = 0.3
local BOX_DELAY = 0.1
local BOX_TWEEN = 0.15
local BOX_STRETCH = 0.15

local RECT_SIZE = 16*GAME_SCALE

function State:new(stage)
	self.index = 1

	self.music = makeAudio("assets/music/mamoru/FineDay.ogg", "stream")
	self.music:setLooping(true)

	self.sprites = {}
	self.icons = {}

	self.charTween = 0
	self.boxDelay = 0
	self.boxTween = 0
	self.boxStretch = 0
	self.rect_off = 0
	self.stage = stage

	for k,v in pairs(Characters) do
		local sprite = Sprite("assets/data/characters/"..v.path.."/render.png", 0,0)
		local icon = Sprite("assets/data/characters/"..v.path.."/icon.png", 0,300)
		local scale = HEIGHT/sprite.height

		sprite.origin = {x=0, y=0.5}
		sprite.scale = scale
		sprite.x = GAME_WIDTH-50-sprite.width*scale
		sprite.y = GAME_HEIGHT/2

		icon.scale = GAME_SCALE
		icon.origin = {x=0, y=1}

		self.sprites[k] = sprite
		self.icons[k] = icon
	end
end

function State:enter()
	self.music:play()
end

function State:select(i)
	if i == 0 then return end

	local prevSel = self.index
	self.index = mathx.clamp(self.index+i, 1, #Characters)

	if prevSel == self.index then return end

	self.charTween = 0
	self.boxDelay = 0
	self.boxTween = 0
	self.boxStretch = 0
end

function State:exit()
	self.music:stop()
end

function State:update(dt)
	local dir = 0

	if Controls:pressed("left") then
		dir = dir - 1
	end
	if Controls:pressed("right") then
		dir = dir + 1
	end

	self.charTween = mathx.approach(self.charTween, CHARACTER_TWEEN, dt)
	if self.boxDelay >= BOX_DELAY then
		self.boxTween = mathx.approach(self.boxTween, BOX_TWEEN, dt)
	end
	self.boxStretch = mathx.approach(self.boxStretch, BOX_STRETCH, dt)
	self.boxDelay = mathx.approach(self.boxDelay, BOX_DELAY, dt)

	self:select(dir)

	local end_x = GAME_WIDTH-50-self.sprites[self.index].width*self.sprites[self.index].scale
	local start_x = GAME_WIDTH

	self.sprites[self.index].x = Ease.outQuad(self.charTween, start_x, end_x-start_x, CHARACTER_TWEEN)

	local x = 12*GAME_SCALE
	
	for k,v in pairs(self.icons) do
		v.scale = k == self.index and GAME_SCALE*1.5 or GAME_SCALE

		v.x = x
		x = x + 16*v.scale
	end

	self.rect_off = (self.rect_off + 2) % RECT_SIZE

	if Controls:pressed("a") then
		local state = require("states.game")(self.stage, Characters[self.index])
		Gamestate:change(state, Mosiac, Mosiac)
	end
end

function State:draw()
	local character = Characters[self.index]
	local r,g,b,a = love.graphics.getColor()

	local finish_radius = 50*GAME_SCALE
	local start_radius = 5*GAME_SCALE
	local radius = Ease.outQuad(self.boxStretch, start_radius, finish_radius-start_radius, BOX_STRETCH)

	local finish_radius = 20*GAME_SCALE
	local start_radius = 2*GAME_SCALE
	local small_radius = Ease.outQuad(self.boxStretch, start_radius, finish_radius-start_radius, BOX_STRETCH)

	local y = GAME_HEIGHT/2 - radius/2

	local box_x = Ease.outQuad(self.boxTween, -GAME_WIDTH, GAME_WIDTH, BOX_TWEEN)

	absoluteColor:send("absColor", character.color)

	-- BACKGROUND
	local colors = {
		{255/255,150/255,170/255,1},
		{255/255,181/255,198/255,1}
	}
	local color = 1
	for y = -1, GAME_HEIGHT/RECT_SIZE do
		color = color == 1 and 2 or 1
		local color = color
		for x = -1, GAME_WIDTH/RECT_SIZE do
			color = color == 1 and 2 or 1
			love.graphics.setColor(colors[color])

			love.graphics.rectangle("fill",
				self.rect_off + x*RECT_SIZE,
				self.rect_off + y*RECT_SIZE,
				RECT_SIZE,
				RECT_SIZE
			)

			love.graphics.setColor(r,g,b,a)
		end
	end

	-- RECTANGLE
	love.graphics.setColor(character.color)
	love.graphics.rectangle("fill",
		0,
		y,
		GAME_WIDTH,
		radius
	)
	love.graphics.rectangle("fill",
		0,
		255-small_radius/2,
		GAME_WIDTH,
		small_radius
	)
	love.graphics.setColor(r,g,b,a)

	-- ICONS
	if self.boxTween == BOX_TWEEN then
		for k,v in pairs(self.icons) do
			v:draw()
		end
	end

	-- SELECTED PLAYER
	love.graphics.push()
	love.graphics.translate(12, 12)
		love.graphics.setShader(absoluteColor)
			self.sprites[self.index]:draw()
		love.graphics.setShader()
	love.graphics.pop()
	self.sprites[self.index]:draw()

	-- NAME
	love.graphics.print(character.name,
		box_x+4*GAME_SCALE,
		y+4*GAME_SCALE,
		0,
		GAME_SCALE*0.75
	)
	love.graphics.print(character.subname,
		box_x+4*GAME_SCALE,
		y+16*GAME_SCALE,
		0,
		GAME_SCALE*0.5
	)
end

return State