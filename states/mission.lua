local State = require "objects.State"
local Sprite = require "objects.Sprite"
local Mosiac = require "objects.transitions.Mosiac"
local CharacterSelect = require "states.mamonoro.character"
local MissionSelect = class{name = "MissionSelect", extends = State}

MissionSelect.MAMONORO_SCALE = 1.5
MissionSelect.stages = {
	{
		name = "Test",
		path = "test",
		icon = "stage1",
		cleared = false,
		dialogue = {portrait = {1,1}, dialogue = "i am fululu higokudani"}
	},
	{
		name = "Test 2",
		path = "test2",
		icon = "stage2",
		cleared = true,
		dialogue = {portrait = {2,1}, dialogue = "i am still fululu higokudani"}
	}
}

MissionSelect.current = 1

local UNSELECTED_X = -300
local SELECTED_X = 50

function MissionSelect:new()
	self:super()
	self.sprites = {}

	-- background
	self.background = Sprite("assets/images/ui/parallax/mamonoro_mission.png", 0,0)
	self.background.momx = -1
	self.background.momy = -1.25
	self.background.parallax = true

	-- stage select
	self.stageSelect = Sprite("assets/images/ui/missions/stageSelect.png", 0,0)
	self.stageSelect.x = 100
	self.stageSelect.y = 80
	self.stageSelect.scale = self.MAMONORO_SCALE

	-- stages
	self.stageDisplays = {}
	for i,data in ipairs(self.stages) do
		local sprite = Sprite("assets/images/ui/missions/"..data.icon..".png", UNSELECTED_X, GAME_HEIGHT/2)
		sprite.origin.y = 0.5
		sprite.scale = self.MAMONORO_SCALE

		self.stageDisplays[i] = sprite
	end

	-- dialogue portrait and box
	self.box = Sprite("assets/images/ui/boxes/dialogue.png", 0,0)
	self.box.scale = self.MAMONORO_SCALE

	self.frame = Sprite("assets/images/ui/boxes/frame.png", 0,0)
	self.frame.scale = self.MAMONORO_SCALE

	local offset = 8
	local groupWidth = (self.box.width+offset+self.frame.width)*self.MAMONORO_SCALE

	self.frame.x = (GAME_WIDTH/2)-(groupWidth/2)
	self.frame.y = GAME_HEIGHT - (self.frame.height*self.frame.scale) - 60

	self.box.x = self.frame.x+((self.frame.width+offset)*self.MAMONORO_SCALE)
	self.box.y = self.frame.y

	local pos = (8*self.MAMONORO_SCALE)
	self.fululu = Sprite(nil, self.frame.x+pos, self.frame.y+pos)
	self.fululu.scale = self.MAMONORO_SCALE
	self.fululu:setSpriteSheet("assets/images/ui/portraits/fululu_big.png", 3, 2)
	self.fululu:setQuad(1, 1)

	table.insert(self.sprites, self.background)
	table.insert(self.sprites, self.stageSelect)
	for i = 1,#self.stageDisplays do
		table.insert(self.sprites, self.stageDisplays[i])
	end

	table.insert(self.sprites, self.frame)
	table.insert(self.sprites, self.fululu)
	table.insert(self.sprites, self.box)
end

function MissionSelect:enter()
	-- music
	self.music = makeAudio("assets/music/mamoru/SacredTree.ogg", "stream")
	self.music:setLooping(true)
	self.music:play()
end

function MissionSelect:update(dt)
	for _,sprite in pairs(self.sprites) do
		sprite:update(dt)
	end

	local dir = 0
	if Controls:pressed"left" then
		dir = dir - 1
	end
	if Controls:pressed"right" then
		dir = dir + 1
	end
	self:change(dir)

	for i,sprite in pairs(self.stageDisplays) do
		sprite.x = mathx.lerp(
			sprite.x,
			i == self.current and SELECTED_X or UNSELECTED_X,
			0.25)
	end

	if Controls:pressed("a") then
		local state = CharacterSelect(self.stages[self.current].path)

		Gamestate:change(state, Mosiac, Mosiac)
	end
end

function MissionSelect:change(i)
	if i == 0 then return end

	self.current = mathx.clamp(self.current+i, 1, #self.stages)
	local data = self.stages[self.current]

	self.fululu:setQuad(unpack(data.dialogue.portrait))
end

function MissionSelect:exit()
	self.music:stop()
end

function MissionSelect:draw()
	for _,sprite in pairs(self.sprites) do
		sprite:draw()
	end

	local scale = 2
	local width = (self.box.width*self.box.scale - 32)/scale
	local text = self.stages[self.current].dialogue.dialogue

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(
		text,
		self.box.x+16-scale,
		self.box.y+16-scale,
		width,
		"left",
		0,
		scale,
		scale)
	love.graphics.setColor(1,1,1,1)
	love.graphics.printf(
		text,
		self.box.x+16,
		self.box.y+16,
		width,
		"left",
		0,
		scale,
		scale)
end

return MissionSelect