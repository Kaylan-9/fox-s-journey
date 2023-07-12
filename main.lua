_G.screen= {
  w= love.graphics.getWidth(),
  h= love.graphics.getHeight(),
}
_G.tbl= require('useful.tbl')
_G.timer= require('useful.timer')
_G.mathK= require('useful.mathK')
_G.json= require('useful.json')
_G.dt= 0

local ScreenManager= require('manager.screenManager')
local ObjManager= require('manager.objManager')
local TilesManager= require('manager.tilesManager')
local KeyboardMouseManager = require("manager.keyboardMouseManager")
local Map= require('map.map')
local map= Map()

local Game= {
  game_stage_n= 1,
  game_stages= json.import('data/game_stages.json'),
  game_stage_data= {},
  current_screen= 'options'
}

function Game:loadStage()
  self.game_stage_data= self.game_stages[self.game_stage_n]
end

function Game:load()
  self:loadStage()
  love.graphics.setLineWidth(0.5)
  love.graphics.setDefaultFilter('nearest', 'nearest')
  TilesManager:load()
  ScreenManager:load()
  map:load(self.game_stage_data.map)
  ObjManager:load()
end

function Game:keypressed(key)
  ScreenManager:keypressed(key)
end

function Game:update(dt)
  _G.dt= dt
  KeyboardMouseManager:update()
  ObjManager:update()
end

function Game:draw()
  ObjManager:draw()
end

function love.load() Game:load() end
function love.keypressed(key) Game:keypressed(key) end
function love.update(dt) Game:update(dt) end
function love:draw() Game:draw() end