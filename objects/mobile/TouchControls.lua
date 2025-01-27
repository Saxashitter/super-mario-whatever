local TouchControls = class{name = "TouchControls"}
local JOYSTICK_DEADZONE = 0.3

function TouchControls:new()
	self.buttons = {}
	self.joysticks = {}

	self._touches = {}
end

function TouchControls:addTouch(touch)
	self._touches[touch] = 0
end
function TouchControls:removeTouch(touch)
	self._touches[touch] = nil
end

function TouchControls:button(name, x, y, radius)
	local button = {}

	button.x = x or 0
	button.y = y or 0
	button.pressed = false
	button.forced = false
	button.radius = radius or 16
	button.frames = -1

	self.buttons[name] = button
end

local function is_in_direction(x, y, i)
	if i == 1 then
		return x < -JOYSTICK_DEADZONE
	end
	if i == 2 then
		return y > JOYSTICK_DEADZONE
	end
	if i == 3 then
		return y < -JOYSTICK_DEADZONE
	end
	if i == 4 then
		return x > JOYSTICK_DEADZONE
	end

	return false
end

function TouchControls:joystick(name, x, y, radius, digital)
	local stick = {}

	stick.x = x or 0
	stick.y = y or 0
	stick.touched = false -- diddy
	stick.radius = radius or 32
	stick.digital = (digital)

	if digital then
		local keys = {}

		for k,v in pairs(digital) do
			keys[k] = {name = v, frames = -1}
		end

		stick._keys = keys
	end

	self.joysticks[name] = stick
	return stick
end

local function get_button_frames(self, name)
	if self.buttons[name] then
		local button = self.buttons[name]

		return button.frames
	end

	for i,stick in pairs(self.joysticks) do
		if stick.digital then
			local exists, index, frames

			for i,data in pairs(stick._keys) do
				if data.name == name then
					exists = true
					frames = data.frames
					index = i
					break
				end
			end

			if exists then
				return frames
			end
		end
	end

	return -1
end

function TouchControls:down(name)
	return get_button_frames(self, name) >= 0
end
function TouchControls:pressed(name)
	return get_button_frames(self, name) == 0
end

function TouchControls:update()
	for _,stick in pairs(self.joysticks) do
		if stick.pressed
		and self._touches[stick.pressed] == nil then
			stick.pressed = false
		end

		for touch,frames in pairs(self._touches) do
			local x, y = love.touch.getPosition(touch)
			local dist = mathx.distance(x, y, stick.x, stick.y)

			if frames == 0 then
				if dist < stick.radius then
					stick.pressed = touch
				end
			end
		end

		if stick.digital then
			local x, y = self:getAxis(_)
			local dist = mathx.length(x, y)

			for i,key in pairs(stick._keys) do
				key.frames = is_in_direction(x, y, i) and key.frames+1 or -1
			end
		end
	end
	for _,button in pairs(self.buttons) do
		button.pressed = false

		if button.forced
		and self._touches[button.forced] == nil then
			button.forced = false
		end

		for touch,frames in pairs(self._touches) do
			local x, y = love.touch.getPosition(touch)
			local dist = mathx.distance(x, y, button.x, button.y)

			if dist < button.radius then
				button.pressed = true
				if frames == 0 then
					button.forced = touch
				end
			end
		end

		button.frames = (button.pressed or button.forced) and button.frames+1 or -1
	end
	for touch,_ in pairs(self._touches) do
		self._touches[touch] = self._touches[touch]+1
	end
end

function TouchControls:getAxis(name)
	if not self.joysticks[name] then
		return
	end

	local stick = self.joysticks[name]
	if not stick.pressed then return 0, 0 end

	local x, y = love.touch.getPosition(stick.pressed)

	x = x - stick.x
	y = y - stick.y

	if mathx.length(x, y) > stick.radius then
		local angle = math.atan2(y, x)

		x = stick.radius*math.cos(angle)
		y = stick.radius*math.sin(angle)
	end

	return x/stick.radius, y/stick.radius
end

function TouchControls:draw()
	local r,g,b,a = love.graphics.getColor()
	for _,stick in pairs(self.joysticks) do
		love.graphics.setColor(0.2,0.2,0.2,1)
		love.graphics.circle("fill", stick.x, stick.y, stick.radius)

		local x = stick.x
		local y = stick.y

		if stick.pressed
		and self._touches[stick.pressed] then
			x, y = love.touch.getPosition(stick.pressed)

			if mathx.distance(stick.x, stick.y, x,y) > stick.radius then
				local angle = math.atan2(y-stick.y, x-stick.x)
	
				x = stick.x+stick.radius*math.cos(angle)
				y = stick.y+stick.radius*math.sin(angle)
			end
		end

		love.graphics.setColor(0.5,0,0,1)
		love.graphics.circle("fill", x, y, stick.radius/2)
	end

	for _,button in pairs(self.buttons) do
		love.graphics.setColor(0.5,0.1,0.1,1)
		local radius = button.radius

		if button.frames >= 0 then
			radius = radius*0.75
		end

		love.graphics.circle("fill", button.x, button.y, radius)
	end
	love.graphics.setColor(r,g,b,a)
end

return TouchControls