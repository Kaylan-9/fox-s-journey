local Character= require('models.character')
local NPCs, metatable= {}, {
  __call= function(self, npcs, boss)
    local obj= {}
    obj.options= json.import('data/options_npcs.json')
    obj.on_the_screen= {} --cada tabela é um personagem em cena
    obj.interaction_queue= {} --a fila de NPCs com quem o personagem pode interagir
    obj.boss= {}
    setmetatable(obj, {__index= self})
    obj:load(npcs, boss)
    return obj
  end
}

setmetatable(NPCs, metatable)

local function deepCopy(original)
  local copy
  if type(original) == "table" then
      copy = {}
      for key, value in pairs(original) do
          copy[deepCopy(key)] = deepCopy(value)
      end
      setmetatable(copy, deepCopy(getmetatable(original)))
  else
      copy = original
  end
  return copy
end

function NPCs.createNPC(self, optioname, goto_player, vel, p, messages)
  if(self.options[optioname]~=nil) then
    local option= deepCopy(self.options[optioname])
    local new_character= Character(option, vel, p, messages)
    new_character.goto_player= goto_player
    table.insert(self.on_the_screen, new_character) --adiciona personagem em cena
  end
end 

-- incia quando o jogo incia, mas pode ser utilizado para resetar os NPCs, por exemplo ao iir para a próxima fase 
function NPCs:load(npcs, boss)
  self.on_the_screen= {}
  self.boss= Character(self.options[boss.name], boss.vel, boss.p, boss.messages)
  self.boss.goto_player= true
  self.boss.active= false
  for i=1, #npcs do
    self:createNPC(npcs[i].name, npcs[i].goto_player, npcs[i].vel, npcs[i].p, npcs[i].messages)
  end
end

function NPCs:calcYPositionReferences(i)
  if self.on_the_screen[i].p.f.y==-100 then self.on_the_screen[i].p.y= self.on_the_screen[i].new_y end
end

function NPCs:calcYPositionReferencesBoss()
  if self.boss.p.f.y==-100 then self.boss.p.y= self.boss.new_y end
end

function NPCs:chasePlayer(i)
  local left= (self.on_the_screen[i].p.x+(self.on_the_screen[i].body.w/2))-_G.map.cam.p.x
  local right= (self.on_the_screen[i].p.x-(self.on_the_screen[i].body.w/2))-_G.map.cam.p.x

  local playersLeftSide= _G.player.p.x-(_G.player.body.w/2)
  local playersRightSide= _G.player.p.x+(_G.player.body.w/2)

  if (right>=playersRightSide) and self.on_the_screen[i].goto_player then
    self.on_the_screen[i].animation= 'walking'
    self.on_the_screen[i]:defaultUpdateFrame()
    self.on_the_screen[i].s.x= -math.abs(self.on_the_screen[i].s.x)*self.on_the_screen[i].direction
    self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x - self.on_the_screen[i].mov)
    self.on_the_screen[i].reached_the_player= false
    print(' Direito '..i)
  elseif (left<=playersLeftSide) and self.on_the_screen[i].goto_player then
    self.on_the_screen[i].animation= 'walking'
    self.on_the_screen[i]:defaultUpdateFrame()
    self.on_the_screen[i].s.x= math.abs(self.on_the_screen[i].s.x)*self.on_the_screen[i].direction
    self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x + self.on_the_screen[i].mov)
    self.on_the_screen[i].reached_the_player= false
  else 
    self.on_the_screen[i].reached_the_player= true
  end
end

function NPCs:chasePlayerBoss()
  local left= (self.boss.p.x+(self.boss.body.w/2))-_G.map.cam.p.x
  local right= (self.boss.p.x-(self.boss.body.w/2))-_G.map.cam.p.x

  local playersLeftSide= _G.player.p.x-(_G.player.body.w/2)
  local playersRightSide= _G.player.p.x+(_G.player.body.w/2)

  if (right>=playersRightSide) and self.boss.goto_player then
    self.boss.animation= 'walking'
    self.boss:defaultUpdateFrame()
    self.boss.s.x= -math.abs(self.boss.s.x)*self.boss.direction
    self.boss.p.x= (self.boss.p.x - self.boss.mov)
    self.boss.reached_the_player= false
    print(' Direito '..'boss')
  elseif (left<=playersLeftSide) and self.boss.goto_player then
    self.boss.animation= 'walking'
    self.boss:defaultUpdateFrame()
    self.boss.s.x= math.abs(self.boss.s.x)*self.boss.direction
    self.boss.p.x= (self.boss.p.x + self.boss.mov)
    self.boss.reached_the_player= false
  else 
    self.boss.reached_the_player= true
  end
end

function NPCs:attackPlayer(i)
  if self.on_the_screen[i].hostile then
    self.on_the_screen[i].animation= 'attacking'
    self:dealsDamage(i)
    self.on_the_screen[i]:defaultUpdateFrame()  
  end
end 

function NPCs:attackPlayerBoss()
  if self.boss.hostile then
    self.boss.animation= 'attacking'
    self:dealsDamageBoss()
    self.boss:defaultUpdateFrame()  
  end
end 

function NPCs:dealsDamage(i)  
  if _G.collision:ellipse(_G.player.p, self.on_the_screen[i].p, (self.on_the_screen[i].body.w/2), (self.on_the_screen[i].body.h/2), (self.on_the_screen[i].body.w/2)) then
    -- quando o frame troca o dano é aplicado
    if self.on_the_screen[i].acc>=(self.on_the_screen[i].freq_frames) and self.on_the_screen[i].hostile.attack_frame==self.on_the_screen[i].frame then
      _G.player.life= _G.player.life-self.on_the_screen[i].hostile.damage
    end
  end
end

function NPCs:dealsDamageBoss()  
  if _G.collision:ellipse(_G.player.p, self.boss.p, (self.boss.body.w/2), (self.boss.body.h/2), (self.boss.body.w/2)) then
    -- quando o frame troca o dano é aplicado
    if self.boss.acc>=(self.boss.freq_frames) and self.boss.hostile.attack_frame==self.boss.frame then
      _G.player.life= _G.player.life-self.boss.hostile.damage
    end
  end
end

function NPCs:verSeRetiraDaFilaDeInteracoesComOPlayer()
  local emptying_count= 0
  for j=1, #self.interaction_queue do
    if self.on_the_screen[self.interaction_queue[j-emptying_count]].reached_the_player==false then
      table.remove(self.interaction_queue, j-emptying_count)
      emptying_count= emptying_count+1
    end
  end
end

-- a função abaixo serve para controlar os valores correspondentes aos NPCs, como em que momento o player pode iniciar uma conversasão ou não, e também controla por exemplo até quando o esqueleto se movimentara e também a execução de sua animação
function NPCs:update()
  for i=1, #self.on_the_screen do
    self.on_the_screen[i].acc= self.on_the_screen[i].acc+(_G.dt * math.random(1, 5))
    self.on_the_screen[i].mov= (_G.dt * self.on_the_screen[i].vel * 100) -- o quanto o npc se move
    self.on_the_screen[i]:updateParameters(false)
    self:calcYPositionReferences(i)
    self:chasePlayer(i)
    if self.on_the_screen[i].reached_the_player then
      self:attackPlayer(i)
      table.insert(self.interaction_queue, i)  
    end
  end
  self:verSeRetiraDaFilaDeInteracoesComOPlayer()
  self:inciarInteracao()

  self.boss.acc= self.boss.acc+(_G.dt * math.random(1, 5))
  self.boss.mov= (_G.dt * self.boss.vel * 100)
  self.boss:updateParameters(false)
  self:calcYPositionReferencesBoss()
  self:chasePlayerBoss()
  if self.boss.reached_the_player then
    self:attackPlayerBoss()
  end

end


function NPCs:inciarInteracao()
  if love.keyboard.isDown('f') then 
    if #balloon.messages==0 then
      if #self.interaction_queue>0 then
        _G.balloon.messages= self.on_the_screen[self.interaction_queue[1]].messages
      end
    else
      if _G.balloon.i<#balloon.messages then 
        _G.balloon.i= _G.balloon.i+1
      else 
        _G.balloon.messages= {}
        _G.balloon.i= 1
      end
    end
  end
end


function NPCs:draw() 
  self:drawNPCs()
  self.boss:draw()
  _G.collision:quadDraw(self.boss, _G.map.cam)
end

function NPCs:drawNPCs()
  for i=1, #self.on_the_screen do
    self.on_the_screen[i]:draw(false)
    _G.collision:quadDraw(self.on_the_screen[i], _G.map.cam)
  end
end


return NPCs