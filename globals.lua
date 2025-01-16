-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !! This flag controls the ability to toggle the debug view.         !!
-- !! You will want to turn this to 'true' when you publish your game. !!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
RELEASE = false

GAME_WIDTH = 256
GAME_HEIGHT = 224

GRAVITY = 0.25
PHYSICS_RATE = 1/60

-- Enables the debug stats
DEBUG = not RELEASE

CONFIG = {
    graphics = {
        filter = {
            -- FilterModes: linear (blurry) / nearest (blocky)
            -- Default filter used when scaling down
            down = "nearest",

            -- Default filter used when scaling up
            up = "nearest",

            -- Amount of anisotropic filter performed
            anisotropy = 1,
        }
    },

    window = {
        icon = 'assets/images/icon.png'
    },

    debug = {
        -- The key (scancode) that will toggle the debug state.
        -- Scancodes are independent of keyboard layout so it will always be in the same
        -- position on the keyboard. The positions are based on an American layout.
        key = '`',

        stats = {
            font            = nil, -- set after fonts are created
            fontSize        = 16,
            lineHeight      = 18,
            foreground      = {1, 1, 1, 1},
            shadow          = {0, 0, 0, 1},
            shadowOffset    = {x = 1, y = 1},
            position        = {x = 8, y = 6},

            kilobytes = false,
        },

        -- Error screen config
        error = {
            font            = nil, -- set after fonts are created
            fontSize        = 16,
            background      = {.1, .31, .5},
            foreground      = {1, 1, 1},
            shadow          = {0, 0, 0, .88},
            shadowOffset    = {x = 1, y = 1},
            position        = {x = 70, y = 70},
        },
    }
}

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

CONFIG.debug.stats.font = Fonts.monospace
CONFIG.debug.error.font = Fonts.monospace

-- LIBRARIES
require("lib.batteries"):export()

Slick = require "lib.slick"
Camera = require "lib.camera"
Baton = require "lib.baton"
Lovepad = require "lib.lovepad"
PrintLib = require "lib.print"

Gamestate = state_machine({
	game = require "src.states.game"
})

Maid64 = require "lib.maid64"
Maid64.setup(GAME_WIDTH, GAME_HEIGHT)

-- OBJECTS
local OBJECTS_PATH = "src.objects."

require(OBJECTS_PATH..".player")
require(OBJECTS_PATH..".level")
require(OBJECTS_PATH..".backend.animation")

-- SLICK WORLD
World = Slick.newWorld(GAME_WIDTH, GAME_HEIGHT)

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

Controls:init()