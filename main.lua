local Game= {
  game_stage_n= 0,
  current_screen= 'options'
}

_G.screen= {
  w= love.graphics.getWidth(),
  h= love.graphics.getHeight(),
}
_G.tbl= require('useful.tbl')
_G.timer= require('useful.timer')
_G.mathK= require('useful.mathK')
_G.dt= 0

local ScreenManager= require('manager.screenManager')
local ObjectManager= require('manager.objectManager')
local TilesManager= require('manager.tilesManager')
local KeyboardMouseManager = require("manager.keyboardMouseManager")
local Map= require('map.map')
local map= Map()

function love.load()
  love.graphics.setLineWidth(0.5)
  love.graphics.setDefaultFilter('nearest', 'nearest')
  TilesManager:load()
  ScreenManager:load()
  map:load()
  ObjectManager:load()
end

function love.keypressed(key)
  ScreenManager:keypressed(key)
end

function love.update(dt)
  _G.dt= dt
  KeyboardMouseManager:update()
  ObjectManager:update()
end

function love.draw()
  ObjectManager:draw()
end