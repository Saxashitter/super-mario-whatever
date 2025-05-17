local World = class{name = "World"}

local shash = require("lib.shash")

World.collisionResponses = {}
World.collisionDetections = {}

function World:new(cell)
	self.objects = {}
	self._shash = shash.new(cell)
end

function World.defineCollisionResponse(type1, type2, func, func2)
	if not World.collisionResponses[type1] then
		World.collisionResponses[type1] = {}
	end

	if not World.collisionResponses[type2] then
		World.collisionResponses[type2] = {}
	end

	World.collisionResponses[type1][type2] = func
	World.collisionResponses[type2][type1] = func2 or func
end

function World.defineCollisionDetection(type1, type2, func, func2)
	if not World.collisionDetections[type1] then
		World.collisionDetections[type1] = {}
	end

	if not World.collisionDetections[type2] then
		World.collisionDetections[type2] = {}
	end

	World.collisionDetections[type1][type2] = func
	World.collisionDetections[type2][type1] = func2 or func
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

	self._shash:each(x, y, width, height, function(new)
		if filter and filter(new) then return end
		table.insert(found, new)
	end)

	return found
end

function World:returnResolve(object1, object2, xStep)
	local detections = World.collisionDetections
	local responses = World.collisionResponses

	local detectFuncs = detections[object1.cols.type] or detections.aabb
	local detect = detectFuncs[object2.cols.type] or detectFuncs.aabb

	if not detect(object1, object2) then
		return
	end

	local responseFuncs = responses[object1.cols.type] or responses.aabb
	local response = responseFuncs[object2.cols.type] or responses.aabb

	return response(object1, object2, xStep)
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
	for i = 1, ySteps do
		object.y = object.y + stepY
		self._shash:update(object, object.x, object.y, object.width, object.height)

		for k = #search, 1, -1 do
			vertCols = self:returnResolve(object, search[k])

			if vertCols then
				object.momy = 0
				print "no"
				break
			end
		end
	end

	return horzCols, vertCols
end

local function aabb_aabb_x(e1, e2)
	local mx1 = e1.x+e1.width/2
	local mx2 = e2.x+e2.width/2

	if mx1 > mx2 then
		e1.x = e2.x+e2.width
		return "left"
	else
		e1.x = e2.x-e1.width
		return "right"
	end
end

local function aabb_aabb_y(e1, e2)
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

local function aabb_aabb_overlap(e1, e2)
	return e1.x+e1.width > e2.x
	and e2.x+e2.width > e1.x
	and e1.y+e1.height > e2.y
	and e2.y+e2.height > e1.y
end

local function aabb_aabb(e1, e2, xstep)
	if xstep then
		return aabb_aabb_x(e1, e2)
	end

	return aabb_aabb_y(e1, e2)
end

World.defineCollisionDetection("aabb", "aabb", aabb_aabb_overlap)
World.defineCollisionResponse("aabb", "aabb", aabb_aabb)

return World