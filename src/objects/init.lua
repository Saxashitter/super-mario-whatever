-- OBJECTS
local OBJECTS_PATH = (...)

require(OBJECTS_PATH..".backend.aseprite")
require(OBJECTS_PATH..".backend.animation")
require(OBJECTS_PATH..".backend.gameobject")
require(OBJECTS_PATH..".backend.state")
require(OBJECTS_PATH..".backend.camera")
require(OBJECTS_PATH..".entities.player")
require(OBJECTS_PATH..".tilemap.tileset")
require(OBJECTS_PATH..".tilemap.tile")
require(OBJECTS_PATH..".tilemap.level")
require(OBJECTS_PATH..".ui.sprite")
require(OBJECTS_PATH..".ui.mamonoro.timer")