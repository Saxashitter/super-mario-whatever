VisualSprite = class{name = "HUDAnimate"}

function VisualSprite:new(x, y, properties)
	properties = properties or {}

	self.x = x or 0
	self.y = y or 0
	self.momx = 0
	self.momy = 0
	self.deathTime = -1

	self.image = properties.image

	if not self.image then
		error "No image!"
		return
	end

	self.width = self.image:getWidth()
	self.height = self.image:getWidth()

	self.animated = false
	if properties.animated then
		self.animated = true
		self.animation = Animation(self.image,
			properties.grid,
			properties.anims)
	end
end

function VisualSprite:update(dt)
	local times = dt / (1/60)
	self.x = self.x + (self.momx * times)
	self.y = self.y + (self.momy * times)

	if self.deathTime >= 0 then
		self.deathTime = math.max(0, self.deathTime - dt)

		if self.deathTime == 0 then
			CurrentState:remove(self)
			return
		end
	end

	if not self.animated then return end

	self.animation:update(dt)
end

function VisualSprite:draw()
	if self.animated then
		self.animation:draw(self.x, self.y)
		return
	end

	self.image:draw(self.x, self.y)
end