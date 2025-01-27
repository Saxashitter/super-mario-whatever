local Camera = Class:extend()

function Camera:new()
  self.zoom = GAME_SCALE
  self.target = nil
end

local hw, hh = GAME_WIDTH / 2, GAME_HEIGHT / 2
function Camera:start()
  love.graphics.push()
  love.graphics.translate(hw, hh)
  love.graphics.scale(self.zoom)
  if self.target then
    love.graphics.translate(-self.target.x, -self.target.y)
  end
end

Camera.finish = love.graphics.pop

return Camera
