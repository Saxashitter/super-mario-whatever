MissionSelect = class{name = "MissionSelect", extends = State}

MissionSelect.MAMONORO_SCALE = 1.5
MissionSelect.stages = {
	{
		name = "Test",
		path = "test",
		icon = "stage1",
		cleared = false,
		dialogue = {portrait = "neutral", dialogue = "i am fululu higokudani"}
	},
	{
		name = "Test 2",
		path = "test",
		icon = "stage2",
		cleared = true,
		dialogue = {portrait = "cheer", dialogue = "i am still fululu higokudani"}
	}
}
MissionSelect.current = 1

local UNSELECTED_X = -300
local SELECTED_X = 50

function MissionSelect:new()
	self:super()

	-- background
	self.background = Sprite("assets/images/ui/parallax/mamonoro_mission.png", 0,0)
	self.background.momx = -1
	self.background.momy = -1.25
	self.background.parallax = true

	-- stage select
	self.stageSelect = Sprite("assets/images/ui/missions/stageSelect.png", 10,10)
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
	self.frame.y = GAME_HEIGHT - (self.frame.height*self.frame.scale) - 10

	self.box.x = self.frame.x+((self.frame.width+offset)*self.MAMONORO_SCALE)
	self.box.y = self.frame.y

	local pos = (8*self.MAMONORO_SCALE)
	self.fululu = Sprite(nil, self.frame.x+pos, self.frame.y+pos)
	self.fululu.scale = self.MAMONORO_SCALE
	self.fululu:setSpriteSheet("assets/images/ui/portraits/fululu_big.png", 3, 2)
	self.fululu:setQuad(2, 1)

	self:add(self.background)
	self:add(self.stageSelect)
	for i = 1,#self.stageDisplays do
		self:add(self.stageDisplays[i])
	end

	self:add(self.frame)
	self:add(self.fululu)
	self:add(self.box)
end

function MissionSelect:update(dt)
	State.update(self, dt)

	for i,sprite in pairs(self.stageDisplays) do
		sprite.x = mathx.lerp(
			sprite.x,
			i == self.current and SELECTED_X or UNSELECTED_X,
			0.25)
	end
end

function MissionSelect:draw()
	State.draw(self)
end