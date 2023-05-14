_G.json= require('useful.json')
_G.collision= require('useful.collision')
_G.current_stage_game= 1
_G.screen= {}

_G.screen.fullscreen, _G.screen.fstype= love.window.getFullscreen()
function _G.screen.change_resolution(self)
  if self.fullscreen==false then self.fullscreen= love.window.setFullscreen(true)
  else self.fullscreen= not love.window.setFullscreen(false) end
  self.w, self.h = love.graphics:getDimensions()
end

local Map= require('controllers.map')
local Displayers= require('controllers.displayers')
local Items= require('controllers.items')
local NPCs= require('controllers.npcs')
local Balloon= require('controllers.balloon')

local fases= json.import('data/fases.json')
local function iniFase()
  local fase= fases[_G.current_stage_game]
  _G.dt= 0
  _G.balloon= Balloon()
  _G.map= Map(fase.map_file, fase.background_file)
  _G.displayers= Displayers()
  local inventory, collectibles= {}, {}
  if _G.items then
    inventory= _G.items.inventory
    collectibles= _G.items.collectibles
  end
  _G.items= Items(inventory, collectibles)
  _G.npcs= NPCs(fase.npcs, fase.boss)
  _G.player= require('controllers.player')
end 

function love.load()  
  _G.screen:change_resolution()
  love.graphics.setDefaultFilter("nearest", "nearest")
  iniFase()
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'f11' then _G.screen:change_resolution() 
  end
end


local function passouDeFase()
  if npcs.boss.life<=0 then
    _G.current_stage_game= _G.current_stage_game + 1
    iniFase()
  end
end

function love.update(dt)
  passouDeFase()
  displayers:update()
  _G.dt= dt
  map:update()
  player:update()
  npcs:update()
  balloon:update()
end

function love.draw()         
  map:draw() 
  displayers:draw()
  player:draw(true)
  player:drawExpression()
  npcs:draw()
  balloon:draw()
end
