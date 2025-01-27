local Cartographer = require "lib.Cartographer"
local Slick = require "lib.slick"

local Camera = require "src.objects.backend.Camera"
local Player = require "src.objects.entities.Player"

local Play = (require "src.objects.backend.State"):extend()

function Play:enter()
  Play.super.enter(self)

  self.camera = Camera()

  self.map = Cartographer.load("assets/maps/test/map.lua")
  self.map.camera = self.camera
  self:add(self.map)

  self:add({
    draw = function()
      for _, v in pairs(self.boxes) do
        love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
      end
      for _, v in pairs(self.polygons) do
        love.graphics.polygon("line", unpack(v))
      end
    end,
    camera = self.camera
  })

  self.world = Slick.newWorld(GAME_WIDTH, GAME_HEIGHT)
  self.boxes = {}
  self.polygons = {}

  local worldGroup = {}
  for _, object in ipairs(self.map.layers.collision.objects) do
    if object.shape == "rectangle" then
      table.insert(worldGroup,
        Slick.newRectangleShape(object.x, object.y, object.width, object.height)
      )
      table.insert(self.boxes, object)
    elseif object.shape == "polygon" then
      local polygons = {}

      for k, v in ipairs(object.polygon) do
        table.insert(polygons, object.x + v.x)
        table.insert(polygons, object.y + v.y)
      end

      table.insert(worldGroup,
        Slick.newPolygonShape(polygons)
      )
      table.insert(self.polygons, polygons)
    end
  end
  if #worldGroup >= 1 then
    self.world:add(self, 0, 0, Slick.newShapeGroup(unpack(worldGroup)))
  end

  local playerX, playerY = 0, 0
  for _, object in ipairs(self.map.layers.trigger.objects) do
    if object.type == "spawn" and object.name == "player" then
      playerX, playerY = object.x, object.y
      break
    end
  end
  self.player = Player(playerX, playerY - 20, self.world)
  self.player.camera = self.camera
  self.camera.target = self.player
  self:add(self.player)

  self.world:optimize()
end

return Play
