local character = {
	path = "bubsy",
	name = "Bubsy Bobcat",
	subname = "Who wrote this stuff?!",
	series = "Bubsy",
	owner = "Accolade",
	color = {1,1,0,1},
	selectable = true,
	index = 3
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