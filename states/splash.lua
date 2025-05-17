local State = require "objects.State"
local Sprite = require "objects.Sprite"
local State = class{name = "SplashScreen", extends = State}

local DISCLAIMER = [[This game is not to be sold. If you bought this game from anyone, you have been scammed!

We are not affiliated with SEGA, Nintendo, G.Rev or Gulit. All characters belong to their respectful owners.

We do not gain profit from this game. This game has been made entirely for FREE, and we do not plan to make a profit out of it anytime soon.

we love super maro]]

function State:new()
	self.presentTime = 3
	self.disclaimerTime = 3
	self.delay = 1/2
	self.sounded = false
	self.text_alpha = 0

	-- saxa shitter presents
	self.splash = Sprite("assets/images/splash.png", GAME_WIDTH/2, GAME_HEIGHT/2)
	self.splash.scale = GAME_SCALE
	self.splash.origin = {
		x = 0.5, y = 0.5
	}

	self.coin = makeAudio("assets/sounds/smw/coin.wav", "static")
end

function State:update(dt)
	if self.delay > 0 then
		self.delay = math.max(0, self.delay-dt)
		return
	end

	if not self.sounded then
		self.sounded = true
		self.coin:play()
	end

	self.presentTime = math.max(0, self.presentTime - dt)

	if self.presentTime > 0 then
		return
	end

	self.disclaimerTime = math.max(0, self.disclaimerTime - dt)
	self.splash.y = mathx.lerp(self.splash.y, 32*GAME_SCALE, 0.1)
	self.text_alpha = mathx.approach(self.text_alpha, 1, 0.025)

	if self.disclaimerTime > 0 then
		return
	end

	Gamestate:change(require("states.title")(), nil, require("objects.transitions.Mosiac"))
end

function State:draw()
	if self.delay > 0 then
		return
	end
	local r,g,b,a = love.graphics.getColor()
	local font = love.graphics.getFont()

	self.splash:draw()

	love.graphics.setColor(1,1,1,self.text_alpha)

	local scale = 2

	local height = (font:getHeight()*scale)*7
	local width = font:getWidth(DISCLAIMER)*scale

	love.graphics.printf(
		DISCLAIMER,
		0,
		(GAME_HEIGHT/2)-(height/2),
		GAME_WIDTH/scale,
		"center",
		0,
		scale
	)

	love.graphics.setColor(r,g,b,a)
end

return State