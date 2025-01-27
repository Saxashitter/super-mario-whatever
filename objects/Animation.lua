local Animation = class({
	name = "Animation"
})

function Animation:new(image, gridX, gridY, anims)
	self.image = image
	self.animations = {}
	self.current = {{0, 0}}
	self.name = ""

	self.delta = 0
	self.index = 0
	self.framerate = 1
	self.speed = 1

	self.columns = math.floor(image:getWidth()/gridX)
	self.rows = math.floor(image:getHeight()/gridY)

	self.frames = {}

	for y = 0, self.rows do
		self.frames[y] = {}
		for x = 0, self.columns do
			self.frames[y][x] = love.graphics.newQuad(
				x*gridX,
				y*gridY,
				gridX,
				gridY,
				image:getDimensions()
			)
		end
	end

	if anims then
		for k,v in ipairs(anims) do
			self:defineAnim(v.name, v.frames, v.fps)
		end
		self:switch(anims.default)
	else
		self.frame = {0, 0}
	end
end

-- Frames table is as shown: {{0, 0}, {1, 0}}
function Animation:defineAnim(name, frames, fps)
	local anim = {
		fps = fps or 1,
		frames = frames
	}

	self.animations[name] = anim
end

function Animation:switch(name)
	if not self.animations[name] then return end

	self.delta = 0
	self.index = 0
	self.name = name
	self.current = self.animations[name].frames
	self.framerate = self.animations[name].fps
	self.frame = self.animations[name].frames[1]
end

function Animation:update(dt)
	local dur = 1/self.framerate

	self.delta = self.delta + dt * self.speed

	while self.delta >= dur do
		self.delta = self.delta - dur
		self.index = (self.index + 1) % #self.current
		self.frame = self.current[self.index+1]
	end
end

function Animation:draw(...)
	if not self.frames[self.frame[1]] then return end
	if not self.frames[self.frame[1]][self.frame[2]] then return end

	local frame = self.frames[self.frame[1]][self.frame[2]]

	love.graphics.draw(self.image, frame, ...)
end

return Animation