local loadTimeStart = love.timer.getTime()

require 'globals'

function love.load()
	love.graphics.setDefaultFilter("nearest")
    if DEBUG then
        local loadTimeEnd = love.timer.getTime()
        local loadTime = (loadTimeEnd - loadTimeStart)
        print(("Loaded game in %.3f seconds."):format(loadTime))
    end
end

function love.update(dt)
	Controls:update(dt)
	CurrentState:update(dt)
	PrintLib.update(dt)
end

function love.draw()
	Maid64.start()

	local drawTimeStart = love.timer.getTime()
	CurrentState:draw()
	local drawTimeEnd = love.timer.getTime()
	local drawTime = drawTimeEnd - drawTimeStart

	Maid64.finish()

	if DEBUG then
		love.graphics.push()
		local x, y = 8, 6
		local dy = 18
		local stats = love.graphics.getStats()
		local memoryUnit = "KB"
		local ram = collectgarbage("count")
		local vram = stats.texturememory / 1024

		ram = ram / 1024
		vram = vram / 1024
		memoryUnit = "MB"

		local info = {
		    "FPS: " .. ("%3d"):format(love.timer.getFPS()),
		    "DRAW: " .. ("%7.3fms"):format(mathx.round(drawTime * 1000, .001)),
		    "RAM: " .. string.format("%7.2f", mathx.round(ram, .01)) .. memoryUnit,
		    "VRAM: " .. string.format("%6.2f", mathx.round(vram, .01)) .. memoryUnit,
		    "Draw calls: " .. stats.drawcalls,
		    "Images: " .. stats.images,
		    "Canvases: " .. stats.canvases,
		    "\tSwitches: " .. stats.canvasswitches,
		    "Shader switches: " .. stats.shaderswitches,
		    "Fonts: " .. stats.fonts,
		}
		for i, text in ipairs(info) do
			love.graphics.print(text, x, y + (i-1)*dy)
		end

		PrintLib.draw()
		love.graphics.pop()
	end

	Controls:draw()
end

function love.resize(x,y)
	Maid64.resize(x,y)
end

function love.keypressed(key, code, isRepeat)
    if not RELEASE and code == "`" then
        DEBUG = not DEBUG
    end
end