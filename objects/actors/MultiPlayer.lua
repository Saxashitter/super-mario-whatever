local Object = class{
	name = "MultiPlayer",
	extends = require("objects.GameObject")
}
local Player = require("objects.actors.Player")
local Aseprite = require("objects.Aseprite")

function Object:new(data)
	self.animation = Aseprite("assets/images/aseprite/MarioSheet.aseprite")
	self.dir = 1
	self:updatePlayer(data)
end

function Object:updatePlayer(data)
	self.x = data.x
	self.y = data.y
	self.animation.active = data.anim
	self.animation.frame = data.frame
	self.dir = data.dir
end

function Object:draw()
	self.animation:draw(
		self.x,
		self.y + Player.height,
		0,
		self.dir,
		1,
		48/2,
		48
	)
end

return Object