local Slick = require "lib.slick"

local Object = Class:extend()

function Object:defineShape()
	return Slick.newShapeGroup(
		Slick.newRectangleShape(0, 0, self.width, self.height - self.width / 2),
		Slick.newCircleShape(self.width / 2, self.height - self.width / 2, self.width / 2)
	)
end

function Object:new(width, height, x, y, world)
	self.x = x or 0
	self.y = y or 0
	self.momx = 0
	self.momy = 0
	self.width = width or 8
	self.height = height or 8

	if world then
		world:add(self, self.x, self.y, self:defineShape())
		self.world = world
	end
end

function Object:draw()
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function Object:resize(width, height)
	local ox = self.width - width
	local oy = self.height - height

	self.width = width
	self.height = height

	self.x = self.x + ox
	self.y = self.y + oy
	if self.world then
		self.world:update(self, self.x, self.y, self:defineShape())
	end
end

function Object:isOnGround()
	return self:getGroundContactInfo() == true
end

function Object:getGroundContactInfo()
	if not self.world or self.momy < 0 then
		return false
	end

	local cols, len = self.world:project(self, self.x, self.y, self.x, self.y + 1)

	if len == 0 then
		return false
	end

	for i = 1, len do
		local col = cols[i]
		if math.abs(col.normal.y) > 0 then
			return true, -col.normal.y, col.normal.x
		end
	end

	return false
end

function Object:isWallBlocking(xOffset)
	if not self.world or xOffset == 0 then
		return false
	end

	local actualX, _, _, len = self.world:check(self, self.x + xOffset, self.y)

	if len == 0 then
		return false
	end

	if actualX ~= self.x then
		return false
	end

	return true
end

function Object:move()
	local isWallBlocking = self:isWallBlocking(self.momx)
	if isWallBlocking then
		self.momx = 0
	end

	local isOnGround, groundNormalX, groundNormalY = self:getGroundContactInfo()

	local goalX, goalY
	if isOnGround then
		-- We want to project input along the X axis on to the ground normal.
		--
		-- For a rectangle normal point +Y, this will just be (self.x, self.y) + (1, 0) * (momx, momx)
		-- which is obviously equivalent to (self.x, self.y) + (momx, 0)
		--
		-- But for a slope, we will move along the slope without penetrating the ground,
		-- whether we are going up the slope (against gravity) or down the slope (with gravity).
		--
		-- It's effectively what the "slide" response handler does, but with finer control
		-- and without the additional force of gravity causing us to move down the slope faster.

		if groundNormalX < 0 then
			-- Since our input requires the ground normal to point roughly in the positive X direction,
			-- we will need to rotate the ground normal 180 degrees (i.e., by negating it) so that
			-- when the input is "right", the player moves right and vice versa for left.
			groundNormalX = -groundNormalX
			groundNormalY = -groundNormalY
		end

		goalX = self.momx * groundNormalX + self.x
		goalY = self.momx * groundNormalY + self.y
	else
		-- We are not on the ground so there is no ground normal to project on to.
		goalX = self.momx + self.x
		goalY = self.momy + self.y
	end

	local actualX, actualY, cols, len = self.world:check(self, goalX, goalY)

	local hitGround = false
	if len > 0 and not isOnGround then
		for i = 1, len do
			local col = cols[i]

			if math.abs(col.normal.y) > 0 then
				if not hitGround and self.momy > 0 then
					hitGround = true

					-- Looks like we hit the ground.
					--
					-- We will be using "groundY" as "actualY" in the final resolution so the player doesn't "slide"
					-- down slopes every time they jump straight up without moving along the X axis. The default
					-- collision handler ("slide") will cause a small slide since it projects the goal position along
					-- the movement normal of the surface, and since it's not flat it will be a little to the left
					-- or right (depending on the direction of the slope).
					actualX = cols[i].touch.x
					actualY = cols[i].touch.y
				end

				self.momy = 0
			end
		end
	end
	self.world:update(self, actualX, actualY)

	-- Lastly, we need to handle the case where we walk up past the end of a slope.
	--
	-- We don't want to have a little "hop" where the player overshoots the end
	-- and gravity pulls them back down. If there's a drop after the slope, this
	-- hop is probably OK though.
	cols, len = self.world:project(self, actualX, actualY, actualX, actualY + 1)
	if len > 0 then
		for i = 1, len do
			local col = cols[i]
			if math.abs(col.normal.y) > 0 then
				actualY = col.touch.y
				break
			end
		end

		actualX, actualY = self.world:move(self, actualX, actualY)
	end

	self.x, self.y = actualX, actualY
end

function Object:physics()
	if self.world then
		self:move()
	end
end

return Object
