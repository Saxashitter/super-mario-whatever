local loadTimeStart = love.timer.getTime()

require 'globals'

function love.load()
    love.window.setIcon(love.image.newImageData(CONFIG.window.icon))
    love.graphics.setDefaultFilter(CONFIG.graphics.filter.down,
                                   CONFIG.graphics.filter.up,
                                   CONFIG.graphics.filter.anisotropy)

    -- Draw is left out so we can override it ourselves
    local callbacks = {'update'}
    for k in pairs(love.handlers) do
        callbacks[#callbacks+1] = k
    end

    Gamestate:set_state("game", true)

    if DEBUG then
        local loadTimeEnd = love.timer.getTime()
        local loadTime = (loadTimeEnd - loadTimeStart)
        print(("Loaded game in %.3f seconds."):format(loadTime))
    end
end

function love.update(dt)
	Controls:update(dt)
	Gamestate:update(dt)
	PrintLib.update(dt)
end

function love.draw()
	Maid64.start()

	local drawTimeStart = love.timer.getTime()
	Gamestate:draw()
	local drawTimeEnd = love.timer.getTime()
	local drawTime = drawTimeEnd - drawTimeStart

	Maid64.finish()

	if DEBUG then
		love.graphics.push()
		local x, y = CONFIG.debug.stats.position.x, CONFIG.debug.stats.position.y
		local dy = CONFIG.debug.stats.lineHeight
		local stats = love.graphics.getStats()
		local memoryUnit = "KB"
		local ram = collectgarbage("count")
		local vram = stats.texturememory / 1024
		if not CONFIG.debug.stats.kilobytes then
		    ram = ram / 1024
		    vram = vram / 1024
		    memoryUnit = "MB"
		end
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
			local sx, sy = CONFIG.debug.stats.shadowOffset.x, CONFIG.debug.stats.shadowOffset.y
			love.graphics.setColor(CONFIG.debug.stats.shadow)
			love.graphics.print(text, x + sx, y + sy + (i-1)*dy)
			love.graphics.setColor(CONFIG.debug.stats.foreground)
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
    if not RELEASE and code == CONFIG.debug.key then
        DEBUG = not DEBUG
    end
end