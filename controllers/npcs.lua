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

function NPCs.createNPC(self, optioname, goto_player, vel, p, messages)
  if(self.options[optioname]~=nil) then
    local new_character= Character(self.options[optioname], vel, p, messages)
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

function NPCs:updateFrame(i)
  if self.on_the_screen[i].animation~='' then
    if self.on_the_screen[i].acc>=(self.on_the_screen[i].freq_frames) then
      self.on_the_screen[i].frame= self.on_the_screen[i].frame + 1
      self.on_the_screen[i].acc= 0

      -- A primeira estrutura condicional serve para recomeçar uma animação, após f ele recomeça a animação no frame i
      -- hold_animation é uma propriedade que serve para travar de um frame a outro até a animação anterior chegar ao seu f
      if self.on_the_screen[i].hold_animation==false then
        if
          (self.on_the_screen[i].frame<self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].i or
          self.on_the_screen[i].frame>self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].f)
        then
          self.on_the_screen[i].frame= self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].i
        end
      end

      --- Se a animação não é travada significa que ela está iniciando uma nova animação, essa estrutura basicamente a função de travar animação se ela está no primeiro frame, e quando ele chegar no último ela será destravada
      if self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].until_finished==true then
        self.on_the_screen[i].previous_animation= self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation]
        self.on_the_screen[i].hold_animation= (self.on_the_screen[i].frame<self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].f-1 and self.on_the_screen[i].frame>=self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].i)
      elseif self.on_the_screen[i].previous_animation.until_finished==true and self.on_the_screen[i].hold_animation==true then
        self.on_the_screen[i].hold_animation= (self.on_the_screen[i].frame<self.on_the_screen[i].previous_animation.f-1 and self.on_the_screen[i].frame>=self.on_the_screen[i].previous_animation.i)
      end

    end
  end
end

function NPCs:updateFrameBoss()
  if self.boss.animation~='' then
    if self.boss.acc>=(self.boss.freq_frames) then
      self.boss.frame= self.boss.frame + 1
      self.boss.acc= 0

      -- A primeira estrutura condicional serve para recomeçar uma animação, após f ele recomeça a animação no frame i
      -- hold_animation é uma propriedade que serve para travar de um frame a outro até a animação anterior chegar ao seu f
      if self.boss.hold_animation==false then
        if
          (self.boss.frame<self.boss.frame_positions[self.boss.animation].i or
          self.boss.frame>self.boss.frame_positions[self.boss.animation].f)
        then
          self.boss.frame= self.boss.frame_positions[self.boss.animation].i
        end
      end

      --- Se a animação não é travada significa que ela está iniciando uma nova animação, essa estrutura basicamente a função de travar animação se ela está no primeiro frame, e quando ele chegar no último ela será destravada
      if self.boss.frame_positions[self.boss.animation].until_finished==true then
        self.boss.previous_animation= self.boss.frame_positions[self.boss.animation]
        self.boss.hold_animation= (self.boss.frame<self.boss.frame_positions[self.boss.animation].f-1 and self.boss.frame>=self.boss.frame_positions[self.boss.animation].i)
      elseif self.boss.previous_animation.until_finished==true and self.boss.hold_animation==true then
        self.boss.hold_animation= (self.boss.frame<self.boss.previous_animation.f-1 and self.boss.frame>=self.boss.previous_animation.i)
      end

    end
  end
end


function NPCs:chasePlayer(i)
  if (self.on_the_screen[i].p.x-(self.on_the_screen[i].body.w/2)-_G.map.cam.p.x>=_G.player.p.x+_G.player.tileset.tileSize.w) and self.on_the_screen[i].goto_player==true then
    self.on_the_screen[i].animation= 'walking'
    self:updateFrame(i)
    self.on_the_screen[i].s.x= -math.abs(self.on_the_screen[i].s.x)*self.on_the_screen[i].direction
    self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x - self.on_the_screen[i].mov)
    self.on_the_screen[i].reached_the_player= false
  elseif (self.on_the_screen[i].p.x+(self.on_the_screen[i].body.w/2)-_G.map.cam.p.x<=_G.player.p.x-_G.player.tileset.tileSize.w) and self.on_the_screen[i].goto_player==true then
    self.on_the_screen[i].animation= 'walking'
    self:updateFrame(i)
    self.on_the_screen[i].s.x= math.abs(self.on_the_screen[i].s.x)*self.on_the_screen[i].direction
    self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x + self.on_the_screen[i].mov)
    self.on_the_screen[i].reached_the_player= false
  else 
    self.on_the_screen[i].reached_the_player= true
  end
end

function NPCs:chasePlayerBoss()
  if (math.abs(self.boss.p.x-_G.map.cam.p.x)>=_G.player.p.x) and self.boss.goto_player==true then
    self.boss.animation= 'walking'
    self:updateFrameBoss()
    self.boss.s.x= -math.abs(self.boss.s.x)*self.boss.direction
    self.boss.p.x= (self.boss.p.x - self.boss.mov)
    self.boss.reached_the_player= false
  elseif (math.abs(self.boss.p.x-_G.map.cam.p.x)<=_G.player.p.x) and self.boss.goto_player==true then
    self.boss.animation= 'walking'
    self:updateFrameBoss()
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
    self:updateFrame(i)  
  end
end 

function NPCs:attackPlayerBoss()
  if self.boss.hostile then
    self.boss.animation= 'attacking'
    self:dealsDamageBoss()
    self:updateFrameBoss()  
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
end

function NPCs:drawNPCs()
  for i=1, #self.on_the_screen do
    self.on_the_screen[i]:draw(false)
  end
end


return NPCs