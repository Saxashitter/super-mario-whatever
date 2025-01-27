local Baton = require "lib.Baton"
local Lovepad = require "lib.Lovepad"

-- TODO: refactor into a class
return {
	init = function(self)
		self.baton = Baton.new({
			controls = {
				left = { "key:a", "key:left" },
				down = { "key:s", "key:down" },
				up = { "key:w", "key:up" },
				right = { "key:d", "key:right" },
				jump = { "key:j", "key:space" },
				spin = { "key:k", "key:x" },
				run = { "key:lshift", "key:w" }
			}
		})

		self.buttonIndexes = {
			left = "Left",
			down = "Down",
			up = "Up",
			right = "Right",
			jump = "B",
			run = "Y",
			spin = "A"
		}

		if love._os == "Android" then
			Lovepad:setGamePad(nil, nil, true, true)
		end
	end,
	update = function(self, dt)
		self.baton:update(dt)

		if love._os == "Android" then
			Lovepad:update(dt)
		end
	end,
	draw = function(self)
		if love._os == "Android" then
			Lovepad:draw(dt)
		end
	end,
	pressed = function(self, ctrl)
		local pressed = self.baton:pressed(ctrl)

		if love._os == "Android"
			and not pressed then
			pressed = Lovepad:isPressed(self.buttonIndexes[ctrl])
		end

		return pressed
	end,
	down = function(self, ctrl)
		local down = self.baton:down(ctrl)

		if love._os == "Android"
			and not down then
			down = Lovepad:isDown(self.buttonIndexes[ctrl])
		end

		return down
	end
}
