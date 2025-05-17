local State = class{
	name = "TitleState",
	extends = require("objects.State")
}
local Sprite = require("objects.Sprite")
local Menu = require("objects.Menu")
local Mosiac = require("objects.transitions.Mosiac")

local OPTIONS = {
	{
		name = "Campaigns",
		category = {
			{
				name = "Mamorukun Curse",
				onSelect = function()
					Gamestate:change(require("states.mission")(), Mosiac, Mosiac)
				end
			},
			{
				name = "More to come soon!"
			},
		},
		onSelect = function() print "lol" end
	},
	{
		name = "Options",
		category = {
			{
				name = "we dont have any yet",
				category = {
					{
						name = "why are you still here"
					}
				}
			}
		},
		onSelect = function() print "NOT DONE" end
	},
	{
		name = "Quit",
		onSelect = function() print "YO" end
	}
}

if DEBUG then
	table.insert(OPTIONS, {
		name = "Debug",
		category = {
			{
				name = "Map Editor",
				onSelect = function(self)
					Gamestate:change(require("states.debug.map")())
				end
			},
			{
				name = ".ase Viewer",
				onSelect = function(self)
					print "Not in yet!"
				end
			},
			{
				name = "XY Placement",
				onSelect = function(self)
					print "Not in yet!"
				end
			}
		}
	})
end
local LOOP_POINT = 10.5

function State:new()
	self.border = Sprite("assets/images/sprites/border.png", 0,0)
	self.border.scale = GAME_SCALE

	self.logo = Sprite("assets/images/sprites/logo.png", GAME_WIDTH/2, 0)
	self.logo.scale = GAME_SCALE*0.65
	self.logo.origin = {x = 0.5, y = 0}
	self.logo.y = -self.logo.height*self.logo.scale
	self.logo_bounces = 2

	self.decoder = love.sound.newDecoder("assets/music/title.ogg", 2048)
	self.source = love.audio.newQueueableSource(
		self.decoder:getSampleRate(),
		self.decoder:getBitDepth(),
		self.decoder:getChannelCount(),
		8
	)
	self.source:setVolume(MUSIC_VOLUME*MASTER_VOLUME)
	self.playback = 0

	self.menu = Menu(0,0,OPTIONS)
	self.menu.x = GAME_WIDTH/2 - self.menu:getWidth()/2
	self.menu.y = GAME_HEIGHT - (24*GAME_SCALE) - self.menu:getHeight()
	self.menu.onMenuChange = function(self)
		self.x = GAME_WIDTH/2 - self:getWidth()/2
		self.y = GAME_HEIGHT - (24*GAME_SCALE) - self:getHeight()
	end
end

function State:enter()
end

function State:update(dt)
	while self.source:getFreeBufferCount() > 0 do
		local buffer = self.decoder:decode()
		self.playback = self.playback + buffer:getSampleCount()
		if self.playback >= self.decoder:getDuration() * self.decoder:getSampleRate() then
			self.playback = LOOP_POINT * self.decoder:getSampleRate()
			self.decoder:seek( LOOP_POINT )
		end
		self.source:queue(buffer)
	end
	self.source:play()

	if self.logo_bounces > 0 then
		if self.logo.y >= 0 then
			self.logo_bounces = math.max(0, self.logo_bounces-1)
			self.logo.y = 0
			if self.logo_bounces > 0 then
				self.logo.momy = self.logo.momy*-0.5
			else
				self.logo.momy = 0
			end
		else
			self.logo.momy = self.logo.momy+GRAVITY
		end
	end

	self.logo:update(dt)
	self.border:update(dt)
	self.menu:update(dt)
end

function State:exit()
end

function State:draw()
	self.logo:draw()
	self.border:draw()
	self.menu:draw()
end

return State