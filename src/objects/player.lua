Player = class({
	name = "player"
})

Player.type = "player"
Player.states = {
	normal = require "src.player.normal"
}
Player.state = Player.states.normal

local GRID_SIZE = 64
local ANIMS = {
	idle = {duration = 1/24, frames = {{1,1}, {2,1}}, loop = true}
}

function Player:new(x, y)
	local image = love.graphics.newImage("assets/images/spritesheets/mario.png")

	self.image = image
	self.animation = Animation(image, GRID_SIZE, {
		default = "idle",
		{name = "idle", frames = {{0,0}}, fps = 1},
		{name = "walk", frames = {{0,0}, {0,1}}, fps = 8},
		{name = "jump", frames = {{0,2}}, fps = 1}
	})

	self.x = x or 0
	self.y = y or 0

	self.momx = 0
	self.momy = 0

	self.width = 8
	self.height = 16

	self.dir = 1
	if self.state
	and self.state.enter then
		self.state.enter(self)
	end

	World:add(self, self.x, self.y, Slick.newBoxShape(0,0,self.width,self.height))
end

function Player:change_state(name)
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

local BASE_FRAMERATE = 60

function Player:move()
	local goalX, goalY = self.x+self.momx, self.y+self.momy
	local _, actualY, cols, len = World:move(self, self.x, goalY)

	if len > 0 then
		for i = 1,len do
			local col = cols[i]

			if math.abs(col.normal.x) > math.abs(col.normal.y) then
				self.momx = 0
			else
				self.momy = 0
			end
		end
	end

	local actualX, actualY, cols, len = World:move(self, goalX, actualY)

	if len > 0 then
		for i = 1,len do
			local col = cols[i]

			if math.abs(col.normal.x) > math.abs(col.normal.y) then
				self.momx = 0
			else
				self.momy = 0
			end
		end
	end

	self.x = actualX
	self.y = actualY
end

function Player:physics()
	if self.state
	and self.state.physics then
		self.state.physics(self)
	end
end

function Player:isOnGround()
	if self.momy < 0 then
		return false
	end

	local rects = World:queryRectangle(
		self.x,	math.ceil(self.y+self.height),
		self.width, 1
	)

	return (#rects > 0)
end

function Player:update(dt)
	if self.state
	and self.state.update then
		self.state.update(self, dt)
	end

	self.animation:update(dt)
end

function Player:draw()
	self.animation:draw(
		self.x + self.width/2,
		self.y + self.height,
		0,
		self.dir*-1,
		1,
		GRID_SIZE/2,
		GRID_SIZE
	)

	if DEBUG then
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	end
end