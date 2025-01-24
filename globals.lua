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

require("lib.batteries"):export()
Slick = require "lib.slick"
Baton = require "lib.baton"
Lovepad = require "lib.lovepad"
PrintLib = require "lib.print"
Ease = require "lib.easing"

require("src.objects")
require("src.states")
require("src.controls")

-- GAMESTATE
CurrentState = StateMachine(GameState)