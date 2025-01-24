-- CONTROLS
Controls = { -- TODO: refactor to a class
	init = function(self)
		self.Baton = Baton.new{
			controls = {
				left = {"key:a"},
				down = {"key:s"},
				up = {"key:w"},
				right = {"key:d"},
				jump = {"key:j"},
				spin = {"key:k"},
				run = {"key:lshift"}
			}
		}

		self.ButtonIndexes = {
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
		self.Baton:update(dt)

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
		local pressed = self.Baton:pressed(ctrl)

		if love._os == "Android"
		and not pressed then
			pressed = Lovepad:isPressed(self.ButtonIndexes[ctrl])
		end

		return pressed
	end,
	down = function(self, ctrl)
		local down = self.Baton:down(ctrl)

		if love._os == "Android"
		and not down then
			down = Lovepad:isDown(self.ButtonIndexes[ctrl])
		end

		return down
	end
}

Controls:init()