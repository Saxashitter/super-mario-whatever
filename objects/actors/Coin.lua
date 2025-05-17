local Coin = class{
	name = "Coin",
	extends = require("objects.GameObject")
}
local Animation = require("objects.Animation")

Coin.width = 16
Coin.height = 16

function Coin:new(x, y, _, world)
	self:super(x, y, world)
	self.collected = false
	self.sound = makeAudio("assets/sounds/smw/coin.wav", "static")

	self.animation = Animation(
		makeImage("assets/images/spritesheets/coinsheet.png"),
		16,
		16,
		{
			default = "idle",
			{
				name = "idle",
				fps = 8,
				frames = {
					{0,0},
					{0,1},
					{0,2},
					{0,3}
				}
			},
			{
				name = "collect",
				fps = 12,
				frames = {
					{0,4},
					{0,5},
					{0,6},
					{0,7},
					{0,8},
					{0,9},
				},
				loop = false
			},
		}
	)
end

function Coin:update(dt)
	self.animation:update(dt)

	if self.collected and self.animation.finished then
		self:kill()
	end
end

function Coin:overlap(player)
	if not player.character then return end
	if self.collected then return end

	self.animation:switch "collect"
	self.sound:play()
	self.collected = true
end

function Coin:draw()
	self.animation:draw(
		self.x, self.y
	)

	if not DEBUG then return end

	require("objects.GameObject").draw(self)
end

return Coin