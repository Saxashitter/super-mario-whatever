local _print = print
local VISIBLE_TIME = 5
local print_objects = {}

local printLib = {}

function print(...)
	local args = {...}

	for i = 1,#args do
		table.insert(print_objects, {
			text = args[i],
			time = VISIBLE_TIME
		})

		if #print_objects > 5 then
			table.remove(print_objects, 1)
		end
	end
end

function printLib.update(dt)
	local rmvList = {}

	for i,obj in pairs(print_objects) do
		obj.time = math.max(0, obj.time - dt)

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

function printLib.draw()
	local y = love.graphics.getHeight() - (18 * #print_objects)

	for k,v in pairs(print_objects) do
		love.graphics.print(v.text, 4, y + (18 * (k - 1)))
	end
end

return printLib