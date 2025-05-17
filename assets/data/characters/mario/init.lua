local character = {
	path = "mario",
	name = "Mario",
	subname = "The Plumber In Red",
	series = "Super Mario Bros.",
	owner = "Nintendo",
	color = {1,0,0,1},
	selectable = true,
	index = 1
}

local PATH = (...):gsub("%.", "/")
local SOUNDS = "assets/sounds/smw/"
local STATES = (...)..".states."

function character:changeState(name)
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

local WALL_WIDTH = 4
local WALL_HEIGHT = 8

function character:isAtWall()
	local y = self.y+(self.height*0.5)-(WALL_HEIGHT*0.5)
	if not self.world then return end

	local left = self.world:search(
		self.x-WALL_WIDTH,
		y,
		WALL_WIDTH,
		WALL_HEIGHT)
	local right = self.world:search(
		self.x+self.width,
		y,
		WALL_WIDTH,
		WALL_HEIGHT)

	if #right > 0 then
		return true, 1
	elseif #left > 0 then
		return true, -1
	end

	return false, 0
end

function character:load()
	self.states = {
		normal = require(STATES.."normal"),
		slide = require(STATES.."slide"),
		crouch = require(STATES.."crouch"),
		longjump = require(STATES.."longjump"),
	}
	self.sounds = {
		jump = makeAudio(SOUNDS.."jump.wav", "static"),
		spring = makeAudio(SOUNDS.."spring.wav", "static"),
		spin = makeAudio(SOUNDS.."spin.wav", "static")
	}
	self.runTime = 0

	self.changeState = character.changeState
	self.isAtWall = character.isAtWall
	self.scale = 1/4

	self.state = self.states.normal
	self.state.enter(self)
end

function character:physics()
	if self.state
	and self.state.physics then
		self.state.physics(self)
	end
end

function character:update(dt)
	if self.state
	and self.state.update then
		self.state.update(self, dt)
	end
end

return character