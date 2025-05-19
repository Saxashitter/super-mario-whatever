local Atlas = class{name = "Atlas"}

require "lib.loveanimate"

function Atlas:new(atlasPath, startingAnim)
	local atlas = love.animate.newTextureAtlas()

	atlas:load(atlasPath)
	if startingAnim then
		atlas:play(startingAnim)
	end

	self.__atlas = atlas
	self.speed = 1
end

function Atlas:update(dt)
	self.__atlas:update(dt * self.speed)
end

function Atlas:draw(...)
	self.__atlas:draw(...)
end

function Atlas:switch(newAnim)
	self.__atlas:play(newAnim)
end

return Atlas