local Camera = require "objects.Camera"
local State = class{
	name = "MapEditor",
	extends = require("objects.State")
}

-- this will sadly probably never be finished unless an ui expert works for us :(

local bgColor = {
	r=0.2, g=0.2, b=0.2, a=1
}

local TILE_SIZE = 16

local function handle_camera(self)
	local radius = (GAME_WIDTH/GAME_SCALE)*0.25
	local height = (GAME_HEIGHT/GAME_SCALE)*0.25
end

function State:new()
	self.cursor = {
		x = 0,
		y = 0,
		image = makeImage("assets/images/cursor.png")
	}

	self.camera = Camera(0,0)
	self.camera.scale = GAME_SCALE
end

function State:update(dt)
	local direction = {x=0, y=0}

	if Controls:down("left") then
		direction.x = direction.x - 1
	end
	if Controls:down("right") then
		direction.x = direction.x + 1
	end
	if Controls:down("up") then
		direction.y = direction.y - 1
	end
	if Controls:down("down") then
		direction.y = direction.y + 1
	end

	local speed = 6
	self.cursor.x = self.cursor.x + direction.x * speed
	self.cursor.y = self.cursor.y + direction.y * speed

	self.cursor.x = mathx.clamp(self.cursor.x, 0, GAME_WIDTH)
	self.cursor.y = mathx.clamp(self.cursor.y, 0, GAME_HEIGHT)
end

function State:draw()
	-- Background
	local r,g,b,a = love.graphics.getColor()

	love.graphics.setColor(bgColor.r,bgColor.g,bgColor.b,bgColor.a)
	love.graphics.rectangle("fill", 0,0,GAME_WIDTH,GAME_HEIGHT)
	love.graphics.setColor(r,g,b,a)

	-- Tile grid
	local x, y, scale = self.camera:getPosition()
	local gw = GAME_WIDTH/scale
	local gh = GAME_HEIGHT/scale

	x = x-gw/2
	y = y-gh/2

	for ty = -1, gh/TILE_SIZE do
		for tx = -1, gw/TILE_SIZE do
			local x = ((-x % TILE_SIZE) + (tx * TILE_SIZE))*scale
			local y = ((-y % TILE_SIZE) + (ty * TILE_SIZE))*scale

			love.graphics.rectangle("line",
				x, y, TILE_SIZE*scale, TILE_SIZE*scale)
		end
	end

	love.graphics.print("Editor", 0,0,0,GAME_SCALE/2)

	love.graphics.draw(self.cursor.image,
		self.cursor.x,
		self.cursor.y,
		0,
		GAME_SCALE,
		GAME_SCALE
	)
end

return State