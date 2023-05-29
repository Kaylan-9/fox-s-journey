local Map= require('controllers.map')
local Displayers= require('controllers.displayers')
local Items= require('controllers.items')
local NPCs= require('controllers.npcs')
local Boss= require('controllers.boss')
local Balloon= require('controllers.balloon')
local Player= require('controllers.player')

local menu= require('controllers.menu')
local mainFont= love.graphics.newFont('assets/PixelifySans-Black.otf', 13)

local metatable, Game= {
  __call=function(self)
    local obj= {}
    obj.timer= 0
    setmetatable(obj, {__index=self})

    _G.screen= {
      w= love.graphics.getWidth(),
      h= love.graphics.getHeight()
    }
    _G.fullscreen, _G.fstype= love.window.getFullscreen()
    _G.dt= 0

    obj.fases= json.import('data/fases.json')
    obj.game_stage= 0
    obj.pause= true
    obj.timer_fim_fase= timer:new(1)
    return obj 
  end 
}, {}

setmetatable(Game, metatable)

function Game:nextLevel()
  if self.game_stage<#self.fases then
    self.game_stage= self.game_stage + 1
    self.fase= self.fases[self.game_stage]
  end
end 

function Game:loadMusic()
  self.name_music= self.fases[self.game_stage].music
  if _G.music then _G.music:pause() end
  _G.music= love.audio.newSource('assets/audios/'..self.name_music, 'static')
  music:play()
  music:setLooping(true)
end

function Game:loadLevel()
  self:loadMusic()
  self:loadItems()
  _G.map= Map(self.fase.map)
  if type(self.fase.boss.name)=='string' then _G.boss= Boss(self.fase.boss) end
  _G.npcs= NPCs(self.fase.npcs)
  _G.displayers= Displayers()
  _G.balloon= Balloon()
  _G.player= Player()
end 

-- Separado da função loadLevel, pois o o inventário do player pode estar com algum item específico
function Game:loadItems()
  local inventory, collectibles= {}, {}
  if _G.items then inventory, collectibles= _G.items.inventory, _G.items.collectibles end
  _G.items= Items(self.fase.items, inventory, collectibles)
end

-- !!!!!!!!!!!!!!!

function Game:load()
  love.graphics.setFont(mainFont)
  love.graphics.setDefaultFilter("nearest", "nearest")
  menu:load()
  love.audio.setVolume(0.1)
end

function Game:update()
  menu:update()
 


  if self.pause==false then
    if self.game_stage==0 then
      self:nextLevel()
      self:loadLevel()
    end

    displayers:update()
    map:update()
    npcs:update()
    player:update()
    items:update()
    balloon:update()
    if not boss.was_destroyed then boss:update() end
    if music then music:play() end

    self:levelEnded()
  else 

    if npcs then npcs:pauseAudios() end
    if player then player:pauseAudios() end
    if boss and not boss.was_destroyed then boss:pauseAudios() end
    if music then music:pause() end

  end
end

function Game:draw()
  if self.pause==false then
    if map then map:draw() end
    player:drawExpression()
    npcs:draw()
    if not boss.was_destroyed then boss:draw() end
    items:draw()
    player:draw()
    balloon:draw()
    displayers:draw()
  else
    menu:draw()
  end
end

function Game:keypressed(key, scancode, isrepeat)
  self:controlesTela(key)
  if self.pause==false then
    items:keypressed(key)
    if not boss.was_destroyed then boss:keypressed(key, scancode, isrepeat) end
    npcs:keypressed(key, scancode, isrepeat)
    player:keypressed(key, scancode, isrepeat)
  end
end

function Game:controlesTela(key)
  if key == 'escape' then self.pause= true
  elseif key == 'f11' then self:alternarResolucao() 
  end
end

function Game:parametersToGoToNextStage()
  local boss_morto= _G.boss.was_destroyed
  local zero_npcs= #_G.npcs.on_the_screen==0 and boss_morto
  local ultimo_frame_finishing= _G.player.frame==_G.player.frame_positions.finishing.f
  return (zero_npcs and ultimo_frame_finishing)
end 

function Game:levelEnded()
  if self:parametersToGoToNextStage() then
    self.timer_fim_fase:start()
    if self.timer_fim_fase:finish() then  
      self.timer_fim_fase:reset()
      self:nextLevel()
      self:loadLevel()
    end
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