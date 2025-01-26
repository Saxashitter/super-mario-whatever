Camera = class{name = "Camera"}

Camera.x = 0
Camera.y = 0
Camera.rot = 0
Camera.scale = 1
Camera.deadzone = {x = 0, y = 0}
Camera.offset = {x = 0, y = 0}
Camera.area = {x = 0, y = 0, x2 = 0, y2 = 0}
Camera.noclip = false

function Camera:new(x, y)
	self.x = x or 0
	self.y = y or 0

	self.deadzone = {x=0, y=0}
	self.offset = {x=0, y=0}
	self.area = {x=0, y=0, x2=0, y2=0}
end

function Camera:setDeadzone(x, y)
	self.deadzone = {x=x, y=y, enabled=true}
end
function Camera:setArea(x, y, x2, y2)
	self.area = {x=x, y=y, x2=x2, y2=y2}
end

function Camera:update()
	if self.follow then
		local follow = self.follow

		if self.deadzone.enabled then
			if follow.x < self.x-self.deadzone.x then
				self.x = math.floor(follow.x+self.deadzone.x)
			end
			if follow.x+follow.width > self.x+self.deadzone.x then
				self.x = math.ceil(follow.x+follow.width-self.deadzone.x)
			end
			if follow.y < self.y-self.deadzone.y then
				self.y = math.floor(follow.y+self.deadzone.y)
			end
			if follow.y+follow.height > self.y+self.deadzone.y then
				self.y = math.ceil(follow.y+follow.height-self.deadzone.y)
			end
		else
			self.x = follow.x+(follow.width/2)
			self.y = follow.y+(follow.height/2)
		end
	end
end

function Camera:getPosition()
	local x = self.x+self.offset.x
	local y = self.y+self.offset.y
	local scale = self.scale

	local screenWidth = GAME_WIDTH*0.5/scale
	local screenHeight = GAME_HEIGHT*0.5/scale

	if not self.noclip then
		local areaScale = math.max(self.area.x/self.area.x2, self.area.y/self.area.y2)

		scale = math.max(scale, areaScale)
		screenWidth = GAME_WIDTH*0.5/scale
		screenHeight = GAME_HEIGHT*0.5/scale

		x = mathx.clamp(x, self.area.x+screenWidth, self.area.x2-screenWidth)
		y = mathx.clamp(y, self.area.y+screenHeight, self.area.y2-screenHeight)
	end

	return x, y, scale
end

function Camera:push()
	self._sx,self._sy,self._sw,self._sh = love.graphics.getScissor()
	love.graphics.setScissor(0,0,GAME_WIDTH,GAME_HEIGHT)

	local x, y, scale = self:getPosition()

	love.graphics.push()
	love.graphics.translate(GAME_WIDTH/2, GAME_HEIGHT/2)
	love.graphics.scale(scale)
	love.graphics.rotate(self.rot)
	love.graphics.translate(-x, -y)
end

function Camera:pop()
	love.graphics.pop()
	love.graphics.setScissor(self._sx,self._sy,self._sw,self._sh)
end