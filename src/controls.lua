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
		if love._os == "Android" then
			local controls = TouchControls()
			local width = love.graphics.getWidth()
			local height = love.graphics.getHeight()

			controls:joystick("move", 130, height - 70, 55, {
				"left", "down", "up", "right"
			})
			controls:button("jump", width - 30, height - 40, 30)
			controls:button("run", width - 100, height - 90, 30)
			controls:button("spin", width - 30, height - 140, 30)

			self.mobile = controls
		end
	end,
	update = function(self, dt)
		self.Baton:update(dt)

		if love._os == "Android" then
			self.mobile:update()
		end
	end,
	draw = function(self)
		if love._os == "Android" then
			self.mobile:draw()
		end
	end,
	touchpressed = function(self, id)
		self.mobile:addTouch(id)
	end,
	touchreleased = function(self, id)
		self.mobile:removeTouch(id)
	end,
	pressed = function(self, ctrl)
		local pressed = self.Baton:pressed(ctrl)

		if not pressed
		and love._os == "Android" then
			pressed = self.mobile:pressed(ctrl)
		end

		return pressed
	end,
	down = function(self, ctrl)
		local down = self.Baton:down(ctrl)

		if not down
		and love._os == "Android" then
			down = self.mobile:down(ctrl)
		end

		return down
	end
}

Controls:init()