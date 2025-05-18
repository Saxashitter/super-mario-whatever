local World = class{name = "World"}

local shash = require("lib.shash")

World.collisionResponses = {}
World.collisionDetections = {}

function World:new(cell)
	self.objects = {}
	self._shash = shash.new(cell)
end

function World.defineCollisionResponse(type1, type2, func, func2)
	if func2 == nil then
		func2 = function(object1, object2, ...)
			func(object2, object1, ...)
		end
	end

	if not World.collisionResponses[type1] then
		World.collisionResponses[type1] = {}
	end

	if type2 ~= type1
	and not World.collisionResponses[type2] then
		World.collisionResponses[type2] = {}
	end

	World.collisionResponses[type1][type2] = func
	if type2 ~= type1 then
		World.collisionResponses[type2][type1] = func2
	end
end

function World.defineCollisionDetection(type1, type2, func, func2)
	if func2 == nil then
		func2 = function(object1, object2, ...)
			func(object2, object1, ...)
		end
	end

	if not World.collisionDetections[type1] then
		World.collisionDetections[type1] = {}
	end

	if type2 ~= type1 and not World.collisionDetections[type2] then
		World.collisionDetections[type2] = {}
	end

	World.collisionDetections[type1][type2] = func

	if type2 ~= type1 then
		World.collisionDetections[type2][type1] = func2
	end
end

function World:add(object)
	if self.objects[object] then return end

	self.objects[object] = true
	self._shash:add(object, object.x, object.y, object.width, object.height)
end

function World:remove(object)
	if not self.objects[object] then return end

	self.objects[object] = nil
	self._shash:remove(object)
end

function World:search(x, y, width, height, filter)
	local found = {}
	local gameobject = require("objects.GameObject")

	self._shash:each(x, y, width, height, function(new)
		if filter and filter(new) then return end
		if not self:isOverlapping({
			x=x,
			y=y,
			width=width,
			height=height
		}, new) then return end
		
		table.insert(found, new)
	end)

	return found
end

function World:isOverlapping(object1, object2)
	local detections = World.collisionDetections

	local type1 = object1.cols and object1.cols.type or "aabb"
	local type2 = object2.cols and object2.cols.type or "aabb"

	local detectFuncs = detections[type1]
	if not detectFuncs then return false end

	local detect = detectFuncs[type2]

	if not detect then return false end
	if not detect(self, object1, object2) then return false end

	return true
end

function World:returnResolve(object1, object2, xStep)
	local responses = World.collisionResponses

	local type1 = object1.cols and object1.cols.type or "aabb"
	local type2 = object2.cols and object2.cols.type or "aabb"

	if not self:isOverlapping(object1, object2) then return end

	local responseFuncs = responses[type1]
	if not responseFuncs then return end

	local response = responseFuncs[type2]
	if not response then return end

	return response(self, object1, object2, xStep)
end

local function slope_position(object, slope)
	local ly = tonumber(slope.tile.slope_left)
	local ry = tonumber(slope.tile.slope_right)
	local side = ry > ly
	local lerp = math.max(0, math.min((object.x-slope.x)/slope.width, 1))

	if not side then
		lerp = 1-math.max(0, math.min(((slope.x+slope.width)-(object.x+object.width))/slope.width, 1))
	end

	return slope.y+mathx.lerp(ly, ry, lerp)
end

function World:move(object)
	local mx = object.x+object.width/2
	local my = object.y+object.height/2

	local momx = object.momx
	local momy = object.momy

	local searchWidth = object.width*4
	local searchHeight = object.height*4
	local search = self:search(mx-searchWidth/2, my-searchHeight/2, searchWidth, searchHeight, function(found)
		return found == object
	end)

	local xSteps = math.max(1, math.ceil(momx/8))
	local ySteps = math.max(1, math.ceil(momy/8))
	local stepX = momx/xSteps
	local stepY = momy/ySteps

	local grounded = object:isOnGround()
	local horzCols, vertCols

	for i = 1, xSteps do
		object.x = object.x + stepX
		self._shash:update(object, object.x, object.y, object.width, object.height)

		for k = #search, 1, -1 do
			horzCols = self:returnResolve(object, search[k], true)
	
			if horzCols then
				object.momx = 0
				break
			end
		end
	end

	if grounded
	and not object:isOnGround() then
		local objects = self:search(
			object.x,
			object.y+object.height,
			object.width,
			16
		)

		local y

		for _, found in ipairs(objects) do
			local newY = found.y
			if found.cols.type == "slope" then
				newY = slope_position(object, found)
			end

			if y == nil then
				y = newY
			else
				y = math.min(y, newY)
			end
		end

		if y then
			object.y = y - object.height
		end
	end

	for i = 1, ySteps do
		object.y = object.y + stepY
		self._shash:update(object, object.x, object.y, object.width, object.height)

		for k = #search, 1, -1 do
			vertCols = self:returnResolve(object, search[k])

			if vertCols then
				object.momy = 0
				break
			end
		end
	end

	return horzCols, vertCols
end

local function aabb_aabb_overlap(self, e1, e2)
	local result = e1.x+e1.width > e2.x
	and e2.x+e2.width > e1.x
	and e1.y+e1.height > e2.y
	and e2.y+e2.height > e1.y

	return result
end

local function aabb_aabb_x(self, e1, e2)
	local mx1 = e1.x+e1.width/2
	local mx2 = e2.x+e2.width/2

	local footDist = e1.y+e1.height - e2.y
	if footDist <= 5 then
		local objects = self:search(e2.x,
			e2.y - e1.height,
			1,
			e1.height, function(new)
				return new == e2 or new == e1 or new.cols.type == "slope"
			end)

		if #objects == 0 then
			e1.y = e2.y-e1.height
			return
		end
	end

	if mx1 > mx2 then
		e1.x = e2.x+e2.width
		return "left"
	else
		e1.x = e2.x-e1.width
		return "right"
	end
end

local function aabb_aabb_y(self, e1, e2)
	local my1 = e1.y+e1.height/2
	local my2 = e2.y+e2.height/2

	if my1 > my2 then
		e1.y = e2.y+e2.height
		return "up"
	else
		e1.y = e2.y-e1.height
		return "down"
	end
end

local function aabb_can_collide(self, e1, e2, xstep)
	local omx, omy = e1.x+e1.width/2, e1.y+e1.height/2
	local tmx, tmy = e2.x+e2.width/2, e2.y+e2.height/2

	local x = e2.x
	local y = e2.y
	local w = e2.width
	local h = e2.height

	if xstep then
		x = e2.x+e2.width
		if omx < tmx then
			x = e2.x-e2.width
		end
	else
		y = e2.y+e2.height
		if omy < tmy then
			y = e2.y - e2.height
		end
	end

	local slopes = self:search(x,y,w,h, function(new)
		return not (new.tile and new.tile.slope == true)
	end)

	return #slopes == 0
end

local function aabb_aabb(self, e1, e2, xstep)
	if not aabb_can_collide(self, e1,e2, xstep) then
		return
	end

	if xstep then
		return aabb_aabb_x(self, e1, e2)
	end

	return aabb_aabb_y(self, e1, e2)
end

local function aabb_slope_overlap(self, object, slope)
	local y = slope_position(object, slope)

	return aabb_aabb_overlap(self, object, slope)
	and object.y+object.height > y
end

local function aabb_slope(self, object, slope, xstep)
	local y = slope_position(object, slope)
	local footDist = (object.y+object.height) - (slope.y+slope.height)

	if object.y+object.height > slope.y+slope.height then
		if footDist >= 5 then
			return aabb_aabb(self, object, slope, xstep)
		end
	end

	object.y = y-object.height
end

World.defineCollisionDetection("aabb", "aabb", aabb_aabb_overlap)
World.defineCollisionDetection("aabb", "slope", aabb_slope_overlap)

World.defineCollisionResponse("aabb", "aabb", aabb_aabb)
World.defineCollisionResponse("aabb", "slope", aabb_slope)

return World