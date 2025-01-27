require "lib.MathX"
Class = require "lib.Classic"
local Maid64 = require "lib.Maid64"
local PrintLib = require "lib.Print"

local Controls = require "src.objects.backend.Controls"

--

DEBUG = true
GAME_SCALE = 4
GAME_WIDTH = 256 * GAME_SCALE
GAME_HEIGHT = 224 * GAME_SCALE

function switchState(newState, ...)
	state = newState
	newState:enter(...)
end

--

function love.load()
	love.graphics.setDefaultFilter("nearest")
	Maid64.setup(GAME_WIDTH, GAME_HEIGHT)
	Controls:init()

	switchState((require "src.states.Play")())
end

function love.update(dt)
	Controls:update(dt)
	state:update(dt)
	PrintLib.update(dt)
end

function love.draw()
	local drawTimeStart = love.timer.getTime()
	Maid64.start()
	state:draw()
	Maid64.finish()
	local drawTimeEnd = love.timer.getTime()
	local drawTime = drawTimeEnd - drawTimeStart

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
			"DRAW: " .. ("%7.3fms"):format(math.round(drawTime * 1000, .001)),
			"RAM: " .. string.format("%7.2f", math.round(ram, .01)) .. memoryUnit,
			"VRAM: " .. string.format("%6.2f", math.round(vram, .01)) .. memoryUnit,
			"Draw calls: " .. stats.drawcalls,
			"Images: " .. stats.images,
			"Canvases: " .. stats.canvases,
			"\tSwitches: " .. stats.canvasswitches,
			"Shader switches: " .. stats.shaderswitches,
			"Fonts: " .. stats.fonts,
		}
		for i, text in ipairs(info) do
			love.graphics.print(text, x, y + (i - 1) * dy)
		end

		PrintLib.draw()
		love.graphics.pop()
	end

	Controls:draw()
end

function love.resize(w, h)
	Maid64.resize(w, h)
end
