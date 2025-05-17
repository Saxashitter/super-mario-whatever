local GameObject = require "objects.GameObject"
local Player = require "objects.actors.Player"
local QuestionBox = class{name = "QuestionBox", extends = GameObject}

QuestionBox.collide = true
QuestionBox.width = 16
QuestionBox.height = 16

function QuestionBox:new(x, y, properties, world)
	self:super(x, y, world)
	self._y = 0
	self.wasHit = false
	self.powerup = "coin"

	self.image = makeImage("assets/images/sprites/question.png")
end

function QuestionBox:update()
	self._y = mathx.lerp(self._y, 0, 0.08)
end

function QuestionBox:draw()
	love.graphics.draw(self.image, self.x, self.y+self._y)
end


function QuestionBox:down(player)
	if not player.character then return end

	self._y = -8

	if self.wasHit then return end
	self.wasHit = true

	print "ok a powerup should come out now"
end

return QuestionBox