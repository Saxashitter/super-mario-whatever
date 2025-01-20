TitleState = class{name = "TitleState", extends = State}

function TitleState:new()
	self.tweenValue = 0
	self.tweenDelay = 0.5

	-- Load mario.
	local image = love.graphics.newImage("assets/images/spritesheets/mario.png")

	self.mario = {
		x = 16,
		y = 16,
		width = 8,
		height = 16,
		anim = Animation(image, 64, {
			default = "jump",
			{name = "idle", frames = {{0,0}}, fps = 1},
			{name = "walk", frames = {{0,0}, {0,1}}, fps = 8},
			{name = "jump", frames = {{0,2}}, fps = 1}
		})
	}
	print "mario"
end

function TitleState:update(dt)
	self.mario.anim:update(dt)
end

function TitleState:draw()
	self.mario.anim:draw(
		self.mario.x + self.mario.width/2,
		self.mario.y + self.mario.height,
		0,
		1,
		1,
		32,
		64
	)
	print "draw"
end