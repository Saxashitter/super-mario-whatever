local HUD = class{
	name = "HUD"
}
local Animation = require("objects.Animation")

local TEXT_SCALE = GAME_SCALE*0.75

local LEFT_X = 12*TEXT_SCALE

local LIVES_Y = 12*TEXT_SCALE
local COINS_Y = LIVES_Y+20*GAME_SCALE

function HUD:new(player)
	self.player = player

	self.life = makeImage("assets/data/characters/"..player.characterMeta.path.."/icon.png")
	self.coin = Animation(
		makeImage("assets/images/spritesheets/coinsheet.png"),
		16,
		16,
		{
			default = "idle",
			{name="idle",fps=8,frames = {{0,0},{0,1},{0,2},{0,3}}}
		}
	)
end

function HUD:update(dt)
	self.coin:update(dt)
end

function HUD:draw()
	local font = love.graphics.getFont()

	-- lives
	love.graphics.draw(self.life,
		LEFT_X,
		LIVES_Y,
		0,
		GAME_SCALE)
	love.graphics.print(LIVES,
		LEFT_X+20*GAME_SCALE,
		LIVES_Y+6*GAME_SCALE,
		0,
		TEXT_SCALE)
	-- coins
	self.coin:draw(
		LEFT_X,
		COINS_Y,
		0,
		GAME_SCALE)
	love.graphics.print(self.player.coins,
		LEFT_X+20*GAME_SCALE,
		COINS_Y+4*GAME_SCALE,
		0,
		TEXT_SCALE)
end

return HUD