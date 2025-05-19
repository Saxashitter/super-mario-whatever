local State = require "objects.State"
local Camera = require "objects.Camera"
local Level = require "objects.tilemap.Level"
local HUD = require "objects.ui.HUD"
local World = require "objects.World"
local Actors = require "objects.actors"

local GameState = class{name = "GameState", extends = State}

local function cameraThink(self)
	local x_speed = 4
	local x_offset = 0

	if self.player:isOnGround() then
		self.gameCamera.y = mathx.approach(self.gameCamera.y, self.player.y+(self.player.height/2), 1)
	end
end

function GameState:new(map, character)
	-- reinitialize world to fit world boundaries
	local map = require("assets.data.maps."..map)
	self.map_name = map
	self:super()

	self.entities = {}
	self.world = World()

	self.cameraLockIn = {x = 0, y = 0, width = GAME_WIDTH, height = GAME_HEIGHT, scale = GAME_SCALE}
	self.cameraEase = 0

	self.gameCamera = Camera()
	self.gameCamera:setDeadzone(32, 48)
	self.gameCamera.scale = GAME_SCALE

	self.hudCamera = Camera(GAME_WIDTH/2, GAME_HEIGHT/2)

	self.level = Level(0, 0, map, self.world)

	self.gameCamera:setArea(
		self.level.x,
		self.level.y,
		self.level.width*self.level.tilewidth,
		self.level.height*self.level.tileheight)

	if self.level.markers.object_pos then
		for k,marker in pairs(self.level.markers.object_pos) do
			local class = Actors[marker.properties.type]
			local object = class(marker.x-class.width/2, marker.y-class.height, marker.properties, self.world)

			table.insert(self.entities, object)
		end
	end

	local player_x, player_y = 0,0
	if self.level.markers.player_pos then
		player_x = self.level.markers.player_pos[1].x-(Actors.Player.width/2)
		player_y = self.level.markers.player_pos[1].y-(Actors.Player.height)
	end

	self.player = Actors.Player(player_x, player_y, character, self.world)

	self.gameCamera.x = self.player.x+(self.player.width/2)
	self.gameCamera.y = self.player.y+(self.player.height/2)
	self.gameCamera.follow = self.player

	self.music = makeAudio(
		"assets/music/"..(self.level.properties.music or "mamoru/SacredTree")..".ogg",
		"stream"
	)
	self.music:setLooping(true)
	self.changes = {}

	for k,v in pairs(self.level.songs) do
		table.insert(self.changes, v)
		v.song = makeAudio("assets/music/"..v.path..".ogg", "stream")
		v.song:setLooping(true)
		print("ADDED "..v.path)
	end

	self.hud = HUD(self.player)
end

function GameState:enter()
	self.music:play()
end

function GameState:update(dt)
	if Controls:pressed("menu") then
		Gamestate:change(require("states.title")())
		return
	end
	self.level:update(dt)

	for i = #self.entities, 1, -1 do
		local entity = self.entities[i]

		if not entity._removed then
			entity:update(dt)
			entity:physics(dt)
		end

		if entity._removed then
			table.remove(self.entities, i)
		end
	end

	self.player:update(dt)
	self.player:physics(dt)

	if #self.changes > 0 then
		local changeTo

		for i = #self.changes, 1, -1 do
			if self.player.x > self.changes[i].x then
				changeTo = self.changes[i].song
				table.remove(self.changes, i)
			end
		end

		if changeTo then
			if self._music then
				self._music:stop()
			end
			self._music = self.music

			self.music = changeTo
			self.music:setVolume(0)
			self.music:play()
		end
	end

	if self._music then
		local oldVol = self._music:getVolume()
		local newVol = self.music:getVolume()

		if newVol == 1 then
			self.fading = false
			self._music:stop()
			self._music = nil
		else
			self._music:setVolume(mathx.approach(oldVol, 0, 1/75))
			self.music:setVolume(mathx.approach(newVol, 1, 1/75))
		end
	end

	self.gameCamera:update(dt)
	self.hud:update(dt)
	cameraThink(self)
end

function GameState:exit()
	self.music:stop()
end

function GameState:draw(dt)
	local x, y, scale = self.gameCamera:getPosition()
	local w, h = GAME_WIDTH/scale, GAME_HEIGHT/scale

	self.gameCamera:push()
		self.level:draw(x-w/2, y-h/2, w, h)
	
		for _,entity in ipairs(self.entities) do
			if not entity._removed then
				entity:draw()
			end
		end
		self.player:draw()
	self.gameCamera:pop()

	self.hud:draw()
end

return GameState