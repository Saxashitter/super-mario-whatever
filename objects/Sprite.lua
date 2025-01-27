local Sprite = class{name = "Sprite"}

Sprite.x = 0
Sprite.y = 0
Sprite.rotation = 0
Sprite.scale = 1
Sprite.width = 0
Sprite.height = 0
Sprite.momx = 0
Sprite.momy = 0
Sprite.parallax = false
Sprite.alwaysDraw = false

function Sprite:new(image, x, y)
	self.x = x or 0
	self.y = y or 0
	self.origin = {x=0, y=0}
	self.shaders = {} -- TODO: add post-processing shader library (called pp.lua)

	self:set(image)
end

function Sprite:set(image)
	if image == nil then return end
	if type(image) == "string" then
		image = love.graphics.newImage(image)
	end

	self.spritesheet = nil
	self.quads = nil
	self.curQuad = nil

	self.image = image
	self.width = image:getWidth()
	self.height = image:getHeight()
end

function Sprite:setSpriteSheet(image, columns, rows)
	if image == nil then return end
	if type(image) == "string" then
		image = love.graphics.newImage(image)
	end

	local quadWidth = image:getWidth()/columns
	local quadHeight = image:getHeight()/rows

	self.image = nil
	self.spritesheet = image
	self.quads = {}

	for y = 0,rows-1 do
		self.quads[y+1] = {}

		for x = 0,columns-1 do
			self.quads[y+1][x+1] = love.graphics.newQuad(
				x*quadWidth,
				y*quadHeight,
				quadWidth,
				quadHeight,
				image)
		end
	end

	self.curQuad = self.quads[1][1]
	self.width = quadWidth
	self.height = quadHeight
end

function Sprite:setQuad(column, row)
	if not self.spritesheet then
		error"No spritesheet."
	end
	if not self.quads[row] then
		error"No table exists in row."
	end
	if not self.quads[row][column] then
		error"No quad exists in column."
	end

	self.curQuad = self.quads[row][column]
end

function Sprite:update(dt)
	self.x = self.x + self.momx
	self.y = self.y + self.momy

	if self.parallax then
		self.x = self.x % (self.width*self.scale)
		self.y = self.y % (self.height*self.scale)
	end
end

local function draw_image(self, x, y)
	if self.spritesheet then
		love.graphics.draw(self.spritesheet,
			self.curQuad,
			x, y,
			self.rotation,
			self.scale,
			self.scale,
			self.origin.x*self.width,
			self.origin.y*self.height)
		return
	end

	if self.image == nil then return end

	love.graphics.draw(self.image,
		x, y,
		self.rotation,
		self.scale,
		self.scale,
		self.origin.x*self.width,
		self.origin.y*self.height)
end

function Sprite:draw()
	if self.image == nil and self.spritesheet == nil then
		return
	end

	if not self.parallax then
		draw_image(self, self.x, self.y)
		return
	end

	local width = self.width*self.scale
	local height = self.height*self.scale

	local x = -width + (self.x % width)
	local y = -height + (self.y % height)

	while y < GAME_HEIGHT do
		local x = x

		while x < GAME_WIDTH do
			draw_image(self, x, y)
			x = x + width
		end

		y = y + height
	end
end

return Sprite