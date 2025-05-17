-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !! This flag controls the ability to toggle the debug view.         !!
-- !! You will want to turn this to 'true' when you publish your game. !!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
GAME_SCALE = 4
GAME_WIDTH = 256*GAME_SCALE
GAME_HEIGHT = 240*GAME_SCALE

DEFAULT_LIVES = 3
LIVES = 3

MASTER_VOLUME = 0.5
MUSIC_VOLUME = 1
SOUND_VOLUME = 1

local images = {}
local audios = {}

function clearAudioCache()
	audios = {}
	collectgarbage()
end
function clearImageCache()
	images = {}
	collectgarbage()
end

function makeImage(path, forceNew)
	if images[path]
	and not forceNew then
		return images[path]
	end

	local image = love.graphics.newImage(path)

	if not forceNew then
		images[path] = image
	end

	return image
end

function makeAudio(path, type, forceNew)
	if audios[path] and audios[path][type] and not forceNew then
		return audios[path][type]
	end

	local audio = love.audio.newSource(path, type)
	audio:setVolume((type == "stream" and MUSIC_VOLUME or SOUND_VOLUME)*MASTER_VOLUME)

	if not forceNew then
		if not audios[path] then
			audios[path] = {}
		end
		if not audios[path][type] then
			audios[path][type] = audio
		end
	end

	return audio
end

GRAVITY = 0.280
DEBUG = true

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")

SMWBig = love.graphics.newFont("assets/fonts/big.ttf")
SMWSmall = love.graphics.newFont("assets/fonts/small.ttf")
SMWCredits = love.graphics.newFont("assets/fonts/credits.ttf")

require("lib.batteries"):export()
Baton = require "lib.baton"
PrintLib = require "lib.print"
Ease = require "lib.easing"
Bump = require "lib.bump"
Sock = require "lib.sock"
PP = require "lib.pp"

love.graphics.setFont(SMWBig)