local GameObject = class({
	name = "GameObject"
})

GameObject.width = 8
GameObject.height = 8
GameObject.cols = {
	type = "aabb",
	onOverlap = function() end,
	onResolve = function() end
}

GameObject._removed = false

local function filter(item, other)
	if other.collide then
		return "slide"
	end

	return "cross"
end

local function query_filter(item)
	return (item.collide)
end

function GameObject:new(x, y, world)
	self.x = x or 0
	self.y = y or 0
	self.momx = 0
	self.momy = 0

	if world then
		self.world = world
		self.world:add(self)
	end
end

function GameObject:update(dt)
end

function GameObject:physics()
	self:move()
end

function GameObject:draw()
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function GameObject:resize(width, height, world)
	local ox = (self.width - width)/2
	local oy = self.height - height

	self.width = width
	self.height = height

	self.x = self.x+ox
	self.y = self.y+oy
end

function GameObject:isOnGround()
	if self.momy < 0 then return false end
	if not self.world then return false end

	local objects = self.world:search(self.x,
		self.y+self.height,
		self.width,
		1)

	return #objects > 0
end

function GameObject:move()
	if self.world then
		self.world:move(self)
		return
	end

	self.x = self.x+self.momx
	self.y = self.y+self.momy
end

function GameObject:kill()
	self._removed = true

	if self.world then
		self.world:remove(self)
		self.world = nil
	end
end

function GameObject:getSync()
	return {
		x = self.x,
		y = self.y,
		width = self.width,
		height = self.height
	}
end

local function sync_data(self, data)
	for k,v in pairs(data) do
		if type(v) ~= "table" then
			self[k] = v
		else
			sync_data(self[k], v)
		end
	end
end

function GameObject:sync(data)
	sync_data(self, data)
end

-- COLLISION FUNCTIONS FOR COLLIDING WITH ENTITIES
function GameObject:up() end
function GameObject:down() end
function GameObject:left() end
function GameObject:right() end
function GameObject:overlap() end

return GameObject