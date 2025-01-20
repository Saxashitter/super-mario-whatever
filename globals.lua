-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !! This flag controls the ability to toggle the debug view.         !!
-- !! You will want to turn this to 'true' when you publish your game. !!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
GAME_SCALE = 4
GAME_WIDTH = 256*GAME_SCALE
GAME_HEIGHT = 224*GAME_SCALE

GRAVITY = 0.280
PHYSICS_RATE = 1/60

DEBUG = true

local function makeFont(path)
    return setmetatable({}, {
        __index = function(t, size)
            local f = love.graphics.newFont(path, size)
            rawset(t, size, f)
            return f
        end
    })
end

Fonts = {
    default = nil,

    regular         = makeFont 'assets/fonts/Roboto-Regular.ttf',
    bold            = makeFont 'assets/fonts/Roboto-Bold.ttf',
    light           = makeFont 'assets/fonts/Roboto-Light.ttf',
    thin            = makeFont 'assets/fonts/Roboto-Thin.ttf',
    regularItalic   = makeFont 'assets/fonts/Roboto-Italic.ttf',
    boldItalic      = makeFont 'assets/fonts/Roboto-BoldItalic.ttf',
    lightItalic     = makeFont 'assets/fonts/Roboto-LightItalic.ttf',
    thinItalic      = makeFont 'assets/fonts/Roboto-Italic.ttf',

    monospace       = makeFont 'assets/fonts/RobotoMono-Regular.ttf',
}
Fonts.default = Fonts.regular

-- LIBRARIES
require("lib.batteries"):export()

Slick = require "lib.slick"
Camera = require "lib.camera"
Baton = require "lib.baton"
Lovepad = require "lib.lovepad"
PrintLib = require "lib.print"
Ease = require "lib.easing"

Maid64 = require "lib.maid64"
Maid64.setup(GAME_WIDTH, GAME_HEIGHT)

-- OBJECTS
local OBJECTS_PATH = "src.objects"

require(OBJECTS_PATH..".backend.gameobject")
require(OBJECTS_PATH..".backend.animation")
require(OBJECTS_PATH..".backend.state")
require(OBJECTS_PATH..".tilemap.tileset")
require(OBJECTS_PATH..".tilemap.tile")
require(OBJECTS_PATH..".tilemap.level")
require(OBJECTS_PATH..".entities.player")

-- STATES
local STATE_PATH = "src.states"
require(STATE_PATH..".game")
require(STATE_PATH..".title")

-- SLICK WORLD
World = Slick.newWorld(GAME_WIDTH, GAME_HEIGHT)

-- GAMESTATE
CurrentState = StateMachine(GameState)

-- REDEFINE FOR BIGGER STAGES!
-- CONTROLS

Controls = {
	init = function(self)
		self.Baton = Baton.new{
			controls = {
				left = {"key:a"},
				down = {"key:s"},
				up = {"key:w"},
				right = {"key:d"},
				jump = {"key:j"},
				spin = {"key:k"},
				run = {"key:lshift"}
			}
		}

		self.ButtonIndexes = {
			left = "Left",
			down = "Down",
			up = "Up",
			right = "Right",
			jump = "B",
			run = "Y",
			spin = "A"
		}

		if love._os == "Android" then
			Lovepad:setGamePad(nil, nil, true, true)
		end
	end,
	update = function(self, dt)
		self.Baton:update(dt)

		if love._os == "Android" then
			Lovepad:update(dt)
		end
	end,
	draw = function(self)
		if love._os == "Android" then
			Lovepad:draw(dt)
		end
	end,
	pressed = function(self, ctrl)
		local pressed = self.Baton:pressed(ctrl)

		if love._os == "Android"
		and not pressed then
			pressed = Lovepad:isPressed(self.ButtonIndexes[ctrl])
		end

		return pressed
	end,
	down = function(self, ctrl)
		local down = self.Baton:down(ctrl)

		if love._os == "Android"
		and not down then
			down = Lovepad:isDown(self.ButtonIndexes[ctrl])
		end

		return down
	end
}

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

Controls:init()