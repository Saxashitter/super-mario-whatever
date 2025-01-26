local loadTimeStart = love.timer.getTime()

require 'globals'

local RS = require "lib.resolution_solution"
local canvas

love.resize = function()
  RS.resize()
end

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.graphics.setLineStyle("rough")

	RS.conf{
		game_width = GAME_WIDTH,
		game_height = GAME_HEIGHT,
		scale_mode = 1
	}
	canvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)

	World = Slick.newWorld(GAME_WIDTH, GAME_HEIGHT)
	CurrentState = StateMachine(MissionSelect())

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
	love.graphics.setCanvas(canvas)
	love.graphics.clear(0,0,0,1)

	local drawTimeStart = love.timer.getTime()
	CurrentState:draw()
	local drawTimeEnd = love.timer.getTime()
	local drawTime = drawTimeEnd - drawTimeStart

	love.graphics.setCanvas()
	RS.push()
		love.graphics.draw(canvas)
	RS.pop()

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

function love.keypressed(key, code, isRepeat)
    if not RELEASE and code == "`" then
        DEBUG = not DEBUG
    end
end

function love.touchpressed(id)
	Controls:touchpressed(id)
end
function love.touchreleased(id)
	Controls:touchreleased(id)
end

function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
 
    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local lag = 0.0

    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        -- Cap number of Frames that can be skipped so lag doesn't accumulate
        if love.timer then lag = math.min(lag + love.timer.step(), PHYSICS_RATE * 2) end

        while lag >= PHYSICS_RATE do
            if love.update then love.update(PHYSICS_RATE) end
            lag = lag - PHYSICS_RATE
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
 
            if love.draw then love.draw() end
            love.graphics.present()
        end

        -- Even though we limit tick rate and not frame rate, we might want to cap framerate at 1000 frame rate as mentioned https://love2d.org/forums/viewtopic.php?f=4&t=76998&p=198629&hilit=love.timer.sleep#p160881
        if love.timer then love.timer.sleep(0.001) end
    end
end