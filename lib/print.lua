local _print = print
local VISIBLE_TIME = 5
local print_objects = {}

local printLib = {}

function print(...)
	local args = {...}

	for i = 1,#args do
		_print(tostring(args[i]))
		table.insert(print_objects, {
			text = tostring(args[i]),
			time = VISIBLE_TIME
		})

		if #print_objects > 10 then
			table.remove(print_objects, 1)
		end
	end
end

function printLib.update(dt)
	local rmvList = {}

	for i,obj in pairs(print_objects) do
		obj.time = math.max(0, obj.time - (1/60))

		if obj.time == 0 then
			table.insert(rmvList, obj)
		end
	end

	for _,v in pairs(rmvList) do
		for i,obj in pairs(print_objects) do
			if obj == v then
				table.remove(print_objects, i)
				break
			end
		end
	end
end

local function get_height(str, font)
	local _, count = str:gsub("\n", "\n")

	return font:getHeight() * (count+1)
end

function printLib.draw()
	local font = love.graphics.getFont()
	local y = love.graphics.getHeight()

	for k,v in ipairs(print_objects) do
		y = y - get_height(v.text, font)
	end

	for k,v in ipairs(print_objects) do
		love.graphics.print(v.text, 4, y)
		y = y + get_height(v.text, font)
	end
end

return printLib