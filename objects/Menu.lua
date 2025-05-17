local Menu = class{
	name = "Menu"
}
local Sprite = require("objects.Sprite")

function Menu:new(x, y, options)
	self.list = options
	self.current = 1
	self.parents = {}
	self.scale = 1
	self.x = x or 0
	self.y = y or 0
end

function Menu:update(dt)
	local dir = 0

	if Controls:pressed("up") then
		dir = dir - 1
	end

	if Controls:pressed("down") then
		dir = dir + 1
	end

	if dir ~= 0 then
		self.current = mathx.clamp(self.current+dir, 1, #self.list)
	end
	local options = self.list[self.current]

	if Controls:pressed("left")
	and options.onLeftPress then
		options.onLeftPress(self)
		if self.onOptionChange then
			self:onOptionChange()
		end
	end
	if Controls:pressed("right")
	and options.onRightPress then
		options.onRightPress(self)
		if self.onOptionChange then
			self:onOptionChange()
		end
	end

	if Controls:pressed("a") then
		if options.category then
			table.insert(self.parents, self.list)
			self.current = 1
			self.list = options.category
			if self.onMenuChange then
				self:onMenuChange()
			end
		end

		if options.onSelect then
			options.onSelect(self)
		end
	end

	if Controls:pressed("b") then
		if #self.parents > 0 then
			self.list = self.parents[#self.parents]
			self.current = 1
			if self.onMenuChange then
				self:onMenuChange()
			end
			table.remove(self.parents, #self.parents)
		end
	end
end

local function get_name(self, option)
	local name = option.name or "Unknown"

	if option.get then
		name = name..": "..option.get(self)
	end

	return name
end

function Menu:getWidth()
	local width = 0
	local font = love.graphics.getFont()

	for k,v in pairs(self.list) do
		width = math.max(width, font:getWidth(get_name(self, v)))
	end

	return width
end

function Menu:getHeight()
	local font = love.graphics.getFont()

	return font:getHeight()*#self.list
end

function Menu:draw()
	local r,g,b,a = love.graphics.getColor()
	local font = love.graphics.getFont()
	local scale = 2.25
	local height = font:getHeight()*scale
	local x = self.x+(self:getWidth()/2)

	for i = 1, #self.list do
		local option = self.list[i]
		local str = get_name(self, option)

		local y = self.y
		y = y - height/2
		y = y - (height*#self.list/2)
		y = y + height*i

		if i == self.current then
			love.graphics.setColor(1,1,0,1)
			if option.category then
				str = str
			end
		end

		local width = font:getWidth(str)*scale

		love.graphics.print(str,
			x-(width/2),
			y,
			0,
			scale)
		love.graphics.setColor(r,g,b,a)
	end
end

return Menu