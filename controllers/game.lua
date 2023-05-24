local Map= require('controllers.map')
local Displayers= require('controllers.displayers')
local Items= require('controllers.items')
local NPCs= require('controllers.npcs')
local Boss= require('controllers.boss')
local Balloon= require('controllers.balloon')
local Player= require('controllers.player')

local metatable, Game= {
  __call=function(self)
    local obj= {}
    obj.timer= 0
    setmetatable(obj, {__index=self})
    obj:setProps()
    obj:setTimers()
    return obj 
  end 
}, {}

setmetatable(Game, metatable)

function Game:somaTempo()
  self.timer= self.timer + (_G.dt)
end

function Game:setProps()
  _G.screen= {}
  _G.screen.fullscreen, _G.screen.fstype= love.window.getFullscreen()
  _G.dt= 0
  self.fases= json.import('data/fases.json')
  self.game_stage= 0
end 

local function newTimer(duracao)
  return {
    duracao= duracao,
    t_i= 0,
    t_f= 0,
    start=function(self)
      if self.t_i==0 then
        self.t_i= love.timer.getTime()
      end 
    end,
    reset=function(self)
      self.t_i= 0
      self.t_f= 0
    end,
    finish=function(self)
      self.t_f= love.timer.getTime()
      local perocrrido=  self.t_f - self.t_i
      return perocrrido>=self.duracao
    end
  }
end

function Game:setTimers()
  self.timerFimFase= newTimer(1)
end

function Game:nextLevel()
  if self.game_stage<#self.fases then
    self.game_stage= self.game_stage + 1
    self.fase= self.fases[self.game_stage]
  end
end 

function Game:determinarBoss()
  if type(self.fase.boss.name)=='string' then
    _G.boss= Boss(self.fase.boss)
  end
end 

function Game:loadMusic()
  if self.music then self.music:pause() end
  self.name_music= (_G.boss~=nil and _G.boss.active) and self.fase.bossmusic or self.fase.music
  self.music= love.audio.newSource('assets/audios/'..self.name_music, 'static')
  self.music:play()
  self.music:setLooping(true)
end

function Game:iniciarMusicBoss()
  if _G.boss.active and self.name_music~=self.fase.bossmusic then
    self:loadMusic()
  end
end

function Game:loadLevel()
  self:loadMusic()
  _G.map= Map(self.fase.map)
  self:loadItems()
  self:determinarBoss()
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
  self:alternarResolucao()
  self:loadLevel()
end

function Game:update()
  displayers:update()
  map:update()
  self:iniciarMusicBoss()
  npcs:update()
  player:update()
  items:update()
  balloon:update()
  if not boss.was_destroyed then boss:update() end
  self:levelEnded()
end

function Game:draw()
  if map then map:draw() end
  player:drawExpression()
  npcs:draw()
  if not boss.was_destroyed then boss:draw() end
  items:draw()
  player:draw()
  balloon:draw()
  displayers:draw()
end

function Game:keypressed(key, scancode, isrepeat)
  items:keypressed(key)

  if not boss.was_destroyed then boss:keypressed(key, scancode, isrepeat) end
  npcs:keypressed(key, scancode, isrepeat)
  player:keypressed(key, scancode, isrepeat)
  self:controlesTela(key)
end

function Game:controlesTela(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'f11' then self:alternarResolucao() 
  end
end

function Game:parametersToGoToNextStage()
  local boss_morto= _G.boss.was_destroyed
  local zero_npcs= #_G.npcs.on_the_screen==0 and boss_morto
  local ultimo_frame_finishing= _G.player.frame==_G.player.frame_positions.finishing.f
  return zero_npcs and ultimo_frame_finishing
end 

function Game:levelEnded()
  if self:parametersToGoToNextStage() then
    self.timerFimFase:start()
    if self.timerFimFase:finish() then  
      self.timerFimFase:reset()
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