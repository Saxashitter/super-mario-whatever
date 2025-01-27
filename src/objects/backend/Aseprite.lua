-- alot of this code was copied from the lovease example, idk how to parse aseprite data myself LOL
local LoveAse = require "lib.LoveAse"

local Aseprite = Class:extend()

function Aseprite:new(asePath)
	local ase = LoveAse(asePath)

	self.width = ase.header.width
	self.height = ase.header.height
	self.speed = 1
	self.frames = {}
	self.tags = {}
	self.active = ""
	self.index = 1
	self.time = 0

	for _, frame in ipairs(ase.header.frames) do
		for _, chunk in ipairs(frame.chunks) do
			-- frame image data
			if chunk.type == 0x2005 then
				local cel = chunk.data
				local buffer = love.data.decompress("data", "zlib", cel.data)
				local data = love.image.newImageData(cel.width, cel.height, "rgba8", buffer)
				local image = love.graphics.newImage(data)
				image:setFilter("nearest")

				local ox = 0
				local oy = 0

				table.insert(self.frames, {
					image = image,
					box = { x = cel.x, y = cel.y, w = cel.width, h = cel.h },
					duration = frame.frame_duration / 1000
				})
				-- tag
			elseif chunk.type == 0x2018 then
				for i, tag in ipairs(chunk.data.tags) do
					-- first tag as default
					if i == 1 then
						self.active = tag.name
					end

					-- aseprite use 0 notation to begin
					-- but in lua, everthing starts in 1
					tag.to = tag.to + 1
					tag.from = tag.from + 1
					tag.frames = tag.to - tag.from
					self.tags[tag.name] = tag
				end
			end
		end
	end
end

function Aseprite:update(dt)
	local tag = self.tags[self.active]

	if (tag.to - tag.from) ~= 0 then
		self.time = self.time + dt * self.speed

		-- next frame
		if self.time >= self.frames[self.index].duration then
			self.index = self.index + 1
			self.time = 0 -- you can change to "self.time - frame.duration" as well

			-- reach the end, return to begin
			if self.index > tag.to then
				self.index = tag.from
			end
		end
	end
end

function Aseprite:switch(name)
	if not self.tags[name] then return end

	self.time = 0
	self.active = name
	self.index = self.tags[name].from
end

function Aseprite:draw(...)
	local frame = self.frames[self.index]
	local varargs = { ... }
	local args = {
		varargs[1] or 0,
		varargs[2] or 0,
		varargs[3] or 0,
		varargs[4] or 1,
		varargs[5] or (varargs[4] or 1),
		(varargs[6] or 0) - frame.box.x,
		(varargs[7] or 0) - frame.box.y
	}
	love.graphics.draw(self.frames[self.index].image, unpack(args))
end

return Aseprite
