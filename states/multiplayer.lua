local Sprite = require "objects.Sprite"
local Menu = require("objects.Menu")
local State = class{
	name = "SplashScreen",
	extends = require("objects.State")
}

local MULTIPLAYER_NAME = "Super Mario"
local MULTIPLAYER_SKIN = "mario"
local MULTIPLAYER_PALETTE = "mario_default"

local menu = {
	{
		name = "Player Setup",
		category = {
			{
				name = "Palette Name",
				get = function(self)
					return MULTIPLAYER_PALETTE
				end,
				onSelect = function(self)
					self.namebox = false
					self.textbox = false
					self.palettebox = not self.palettebox
					love.keyboard.setTextInput(self.palettebox)
					if self.palettebox then
						MULTIPLAYER_PALETTE = ""
					end
				end
			},
			{
				name = "Server Name",
				get = function(self)
					return MULTIPLAYER_NAME
				end,
				onSelect = function(self)
					self.namebox = not self.namebox
					self.palettebox = false
					self.textbox = false
					love.keyboard.setTextInput(self.namebox)
					if self.namebox then
						MULTIPLAYER_NAME = ""
					end
				end
			}
		}
	},
	{
		name = "IP",
		get = function(self)
			return self.ip or "0.0.0.0"
		end,
		onSelect = function(self)
			self.namebox = false
			self.palettebox = false
			self.textbox = not self.textbox
			love.keyboard.setTextInput(self.textbox)
			if self.textbox then
				self.ip = ""
			end
		end
	},
	{
		name = "Host",
		onSelect = function(self)
			MULTIPLAYER_DATA = {
				name = MULTIPLAYER_NAME
			}
			Multiplayer:start(true)
			Gamestate:change(require("states.game")("test"))
		end
	},
	{
		name = "Join",
		onSelect = function(self)
			MULTIPLAYER_DATA = {
				name = MULTIPLAYER_NAME
			}
			Multiplayer:start(self.ip)
			Gamestate:change(require("states.game")("test"))
		end
	}
}

local MENU_X = GAME_WIDTH/2
local MENU_Y = GAME_HEIGHT/2

function State:new()
	-- disable keyboard for now
	love.keyboard.setTextInput(false)

	self.menu = Menu(MENU_X, MENU_Y, menu)
	self.menu.x = self.menu.x - self.menu:getWidth()/2
	self.menu.y = self.menu.y - self.menu:getHeight()/2
	self.menu.ip = "localhost"
	self.menu.textbox = false
	self.menu.palettebox = false
	self.menu.namebox = false
	self.menu.onMenuChange = function(self)
		love.keyboard.setTextInput(false)
		self.textbox = false
		self.palettebox = false
		self.namebox = false
	end
end

function State:update(dt)
	self.menu:update(dt)
end

function State:draw()
	self.menu:draw()
end

function State:textinput(t)
	if self.menu.textbox then
		self.menu.ip = self.menu.ip..t
		self.menu.x = MENU_X - self.menu:getWidth()/2
		self.menu.y = MENU_Y - self.menu:getHeight()/2
	end
	if self.menu.palettebox then
		MULTIPLAYER_PALETTE = MULTIPLAYER_PALETTE..t
		self.menu.x = MENU_X - self.menu:getWidth()/2
		self.menu.y = MENU_Y - self.menu:getHeight()/2
	end
	if self.menu.namebox then
		MULTIPLAYER_NAME = MULTIPLAYER_NAME..t
		self.menu.x = MENU_X - self.menu:getWidth()/2
		self.menu.y = MENU_Y - self.menu:getHeight()/2
	end
end

return State