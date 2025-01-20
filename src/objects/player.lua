Player = class({
	name = "Player",
	extends = GameObject
})
Player.states = {
	normal = require "src.player.normal"
}
Player.state = Player.states.normal
Player.width = 10
Player.height = 24
Player.runTime = 1.5

local GRID_SIZE = 48

function Player:new(x, y)
	local image = love.graphics.newImage("assets/images/spritesheets/mario.png")
	image:setFilter("nearest")

	self.image = image
	self.animation = Animation(image, GRID_SIZE, {
		default = "idle",
		{name = "idle", frames = {{5,0}}, fps = 1},
		{name = "walk", frames = {{5,3}, {5,4}, {5,5}}, fps = 12},
		{name = "run", frames = {{5,6}, {5,7}, {5,8}}, fps = 12},
		{name = "jump", frames = {{6,1}}, fps = 1}
	})

	self:super(x, y, true)

	self.runTime = 0
	self.dir = 1

	if self.state
	and self.state.enter then
		self.state.enter(self)
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
	self.animation:draw(
		self.x + self.width/2,
		self.y + self.height,
		0,
		self.dir*-1,
		1,
		GRID_SIZE/2,
		GRID_SIZE-9
	)

	if DEBUG then
		GameObject.draw(self)
	end
end