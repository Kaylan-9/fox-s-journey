local Map= require('controllers.map')
local Displayers= require('controllers.displayers')
local Items= require('controllers.items')
local NPCs= require('controllers.npcs')
local Balloon= require('controllers.balloon')
local Player= require('controllers.player')

local metatable, Game= {
  __call=function(self)
    local obj= {}
    setmetatable(obj, {__index=self})
    obj:setProps()
    return obj 
  end 
}, {}

setmetatable(Game, metatable)

function Game:setProps()
  _G.screen= {}
  _G.screen.fullscreen, _G.screen.fstype= love.window.getFullscreen()
  _G.dt= 0
  self.fases= json.import('data/fases.json')
end 

function Game:nextLevel()
  if self.game_stage then 
    self.game_stage= self.game_stage + 1
  else 
    self.game_stage= 1
  end
end 

function Game:loadLevelData()
  self.fase= self.fases[self.game_stage]
end

function Game:loadLevel()
  self:loadItems()
  _G.map= Map(self.fase.map_file, self.fase.background_file)
  _G.npcs= NPCs(self.fase.npcs)
  _G.displayers= Displayers()
  _G.balloon= Balloon()
  _G.player= Player()
end 

-- Separado da função loadLevel, pois o o inventário do player pode estar com algum item específico
function Game:loadItems()
  local inventory, collectibles= {}, {}
  if _G.items then
    inventory= _G.items.inventory
    collectibles= _G.items.collectibles
  end
  _G.items= Items(self.fase.items, inventory, collectibles)
end

-- !!!!!!!!!!!!!!!

function Game:load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  self:nextLevel()
  self:loadLevelData()
  self:alternarResolucao()
  self:loadLevel()
end

function Game:update()
  displayers:update()
  map:update()
  npcs:update()
  player:update()
  items:update()
  balloon:update()
end

function Game:draw()         
  map:draw() 
  player:draw()
  player:drawExpression()
  npcs:draw()
  items:draw()
  balloon:draw()
  displayers:draw()
end

function Game:keypressed(key, scancode, isrepeat)
  items:keypressed(key)
  npcs:keypressed(key)
  player:keypressed(key, scancode, isrepeat)
  self:controlesTela(key)
end

function Game:controlesTela(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'f11' then self:alternarResolucao() 
  end
end

function Game:alternarResolucao()
  if not self.fullscreen then 
    self.fullscreen= love.window.setFullscreen(true)
  else 
    self.fullscreen= not love.window.setFullscreen(false) 
  end
  _G.screen.w= love.graphics.getWidth() 
  _G.screen.h= love.graphics.getHeight()
end

return Game