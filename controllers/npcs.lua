local Character= require('models.character')

local NPCs, metatable= {}, {
  __call= function(self, boss, npcs)
    local obj= {}
    obj.options= json.import('data/options_npcs.json')
    obj.on_the_screen= {} --cada tabela é um personagem em cena
    obj.number_of_dead= 0 -- para usado depois
    obj.interaction_queue= {} --a fila de NPCs com quem o personagem pode interagir
    obj.boss= {}
    setmetatable(obj, {__index= self})
    obj:load(boss, npcs)
    return obj
  end
}

setmetatable(NPCs, metatable)

function NPCs:load(boss, npcs)
  self:loadBoss(boss)
  self:loadNPCs(npcs)
end

function NPCs:loadBoss(boss) 
  local position= {
    x= _G.map.dimensions.w-600,
    y= -100
  } 
  self.boss= Character(self.options[boss.name], boss.vel, position, false, boss.name, boss.messages)
  self.boss.goto_player= true
  self.boss.active= false
end

-- incia quando o jogo incia, mas pode ser utilizado para resetar os NPCs, por exemplo ao iir para a próxima fase 
function NPCs:loadNPCs(npcs)
  for i=1, #npcs do
    self:createNPC(npcs[i].name, npcs[i].goto_player, npcs[i].vel, npcs[i].p, npcs[i].messages)
  end
end

function NPCs.createNPC(self, optioname, goto_player, vel, p, messages)
  if(self.options[optioname]~=nil) then
    local option= _G.tbl:deepCopy(self.options[optioname])
    local new_character= Character(option, vel, p, false, optioname, messages)
    new_character.goto_player= goto_player
    new_character.lock_movement= {
      left= false, 
      right= false
    }
    table.insert(self.on_the_screen, new_character) --adiciona personagem em cena
  end
end 


function NPCs:calcYPositionReferences(i)
  if self.on_the_screen[i].p.f.y==-100 then self.on_the_screen[i].p.y= self.on_the_screen[i].new_y end
end

function NPCs:calcYPositionReferencesBoss()
  if self.boss.p.f.y==-100 then self.boss.p.y= self.boss.new_y end
end

function NPCs:chasePlayer(i)
  local left= (self.on_the_screen[i].p.x-(self.on_the_screen[i].body.w/2)-1)-_G.map.cam.p.x
  local right= (self.on_the_screen[i].p.x+(self.on_the_screen[i].body.w/2)+1)-_G.map.cam.p.x

  local playersLeftSide= _G.player.p.x-(_G.player.body.w/2)
  local playersRightSide= _G.player.p.x+(_G.player.body.w/2)

  if (left>playersRightSide) and self.on_the_screen[i].goto_player then
    self.on_the_screen[i].animation= 'walking'
    self.on_the_screen[i]:defaultUpdateFrame()
    self.on_the_screen[i].s.x= -math.abs(self.on_the_screen[i].s.x)*self.on_the_screen[i].direction
    self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x - self.on_the_screen[i].mov)
    self.on_the_screen[i].reached_the_player= false
  elseif (right<playersLeftSide) and self.on_the_screen[i].goto_player then
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
  local left= (self.boss.p.x-(self.boss.body.w/2)-1)-_G.map.cam.p.x
  local right= (self.boss.p.x+(self.boss.body.w/2)+1)-_G.map.cam.p.x

  local playersLeftSide= _G.player.p.x-(_G.player.body.w/2)
  local playersRightSide= _G.player.p.x+(_G.player.body.w/2)

  if (left>playersRightSide) and self.boss.goto_player then
    self.boss.animation= 'walking'
    self.boss:defaultUpdateFrame()
    self.boss.s.x= -math.abs(self.boss.s.x)*self.boss.direction
    self.boss.p.x= (self.boss.p.x - self.boss.mov)
    self.boss.reached_the_player= false
  elseif (right<playersLeftSide) and self.boss.goto_player then
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

function NPCs:takesDamageBoss()
  if _G.collision:ellipse(_G.player.p, self.boss.p, (self.boss.body.w/2), (self.boss.body.h/2), (self.boss.body.w/2)) then
    if type(_G.player.hostile.attack_frame)=='table' then
      for j=1, #_G.player.hostile.attack_frame do
        if _G.player.frame==_G.player.hostile.attack_frame[j] then
          if _G.player.acc>=_G.player.freq_frames then
            if self.boss.life> 0 then
              self.boss.life= self.boss.life - _G.player.hostile.damage
            end
          end
        end 
      end
    end
  end
end

function NPCs:takesDamage(i)
  if _G.collision:ellipse(_G.player.p, self.on_the_screen[i].p, (self.on_the_screen[i].body.w/2), (self.on_the_screen[i].body.h/2), (self.on_the_screen[i].body.w/2)) then
    if type(_G.player.hostile.attack_frame)=='table' then
      for j=1, #_G.player.hostile.attack_frame do
        if _G.player.frame==_G.player.hostile.attack_frame[j] then
          if _G.player.acc>=_G.player.freq_frames then
            if self.on_the_screen[i].life> 0 then
              self.on_the_screen[i].life= self.on_the_screen[i].life - _G.player.hostile.damage
            end
          end
        end 
      end
    end
  end
end

function NPCs:dealsDamage(i)  
  if _G.collision:ellipse(_G.player.p, self.on_the_screen[i].p, (self.on_the_screen[i].body.w/2), (self.on_the_screen[i].body.h/2), (self.on_the_screen[i].body.w/2)) then
    -- quando o frame troca o dano é aplicado
    if self.on_the_screen[i].acc>=(self.on_the_screen[i].freq_frames) and self.on_the_screen[i].hostile.attack_frame==self.on_the_screen[i].frame then
      if math.ceil((_G.player.life*#_G.displayers.props_lifeBar.tileset.tiles)/_G.player.maximum_life)>1 then 
        _G.player.life= _G.player.life-self.on_the_screen[i].hostile.damage
      end
    end
  end
end

function NPCs:dealsDamageBoss()  
  if _G.collision:ellipse(_G.player.p, self.boss.p, (self.boss.body.w/2), (self.boss.body.h/2), (self.boss.body.w/2)) then
    -- quando o frame troca o dano é aplicado

    if self.boss.acc>=(self.boss.freq_frames) and self.boss.hostile.attack_frame==self.boss.frame then
      if math.ceil((_G.player.life*#_G.displayers.props_lifeBar.tileset.tiles)/_G.player.maximum_life)>1 then 
        _G.player.life= _G.player.life-self.boss.hostile.damage
      end 
    end
  end
end


function NPCs:verSeRetiraDaFilaDeInteracoesComOPlayer()
  local emptying_count= 0
  for j=1, #self.interaction_queue do
    if self.on_the_screen[self.interaction_queue[j-emptying_count]] then
      if self.on_the_screen[self.interaction_queue[j-emptying_count]].reached_the_player==false then
        table.remove(self.interaction_queue, j-emptying_count)
        emptying_count= emptying_count+1
      end
    end
  end
end

function NPCs:dying(i)
  if math.floor(self.on_the_screen[i].life)==0 then 
    self.on_the_screen[i].animation= 'dying'
    if not self.on_the_screen[i].audios.dying:isPlaying() then self.on_the_screen[i].audios.dying:play() end
    self.on_the_screen[i].goto_player= false
    if self.on_the_screen[i].frame==self.on_the_screen[i].frame_positions['dying'].f then
      if self.on_the_screen[i].acc>=(self.on_the_screen[i].freq_frames) then

        -- apagando interação
        for j=1, #self.interaction_queue do
          if self.interaction_queue[j]~=nil and self.interaction_queue[j]==i then
            table.remove(self.interaction_queue, j)
            break
          end
        end

        self.number_of_dead= self.number_of_dead + 1
        self:removeNPC(i)
      end
    else  
      self.on_the_screen[i]:defaultUpdateFrame() 
    end
  end 
end

function NPCs:removeNPC(i)
  self.on_the_screen[i]= nil
end

function NPCs:updateNPCs()
  for i=1, #self.on_the_screen do
    if self.on_the_screen[i] then
      self.on_the_screen[i].acc= self.on_the_screen[i].acc+(_G.dt * math.random(1, 5))
      self.on_the_screen[i].mov= (_G.dt * self.on_the_screen[i].vel * 100) -- o quanto o npc se move
      self:dying(i)
      if not self.on_the_screen[i] then 
        goto continue
      end
      self.on_the_screen[i]:updateParameters(false)
      self:calcYPositionReferences(i)
      self:chasePlayer(i)
      -- self:impedirMovimentacaoPlayer(i)
      if self.on_the_screen[i].reached_the_player then
        self:attackPlayer(i)
        self:takesDamage(i)
        table.insert(self.interaction_queue, i)  
      end
    end
    ::continue::
  end
  -- verifica se sai da filha de interação com os NPCs
  self:verSeRetiraDaFilaDeInteracoesComOPlayer()
  -- controle de diálogo entre personagem e player
  self:inciarInteracao()
end

function NPCs:updateBoss()
  if self.boss.active then
    self.boss.acc= self.boss.acc+(_G.dt * math.random(1, 5))
    self.boss.mov= (_G.dt * self.boss.vel * 100)
    self.boss:updateParameters(false)
    self:calcYPositionReferencesBoss()
    self:chasePlayerBoss()
    if self.boss.reached_the_player then
      self:attackPlayerBoss()
    end
  end
end

-- a função abaixo serve para controlar os valores correspondentes aos NPCs, como em que momento o player pode iniciar uma conversasão ou não, e também controla por exemplo até quando o esqueleto se movimentara e também a execução de sua animação
function NPCs:update()
  self:updateNPCs()
  self:updateBoss()
end

-- Esse mecânismo serve para a função impedirMovimentaçãoPlayer, invés de subtrair a soma de movimentação do player na horizontal é melhor travar a sua posição com base em uma propriedade para cada NPC
function NPCs:naoPermiteSeMoverPara(direcao)
  local pode= false
  for i=1, #self.on_the_screen do
    if self.on_the_screen[i].lock_movement[direcao] then
      pode= true
      break 
    end
  end
  return pode
end


function NPCs:impedirMovimentacaoPlayer(i)
  local npcLeftSide= self.on_the_screen[i]:getSide('left')
  local npcRightSide= self.on_the_screen[i]:getSide('right')

  local playersLeftSide= _G.player:getSide('left')
  local playersRightSide= _G.player:getSide('right')

  local collisao= collision:quad(self.on_the_screen[i], _G.player, _G.map.cam)
  if collisao then
    if npcLeftSide<=playersRightSide and playersRightSide<=self.on_the_screen[i].p.x-10 then
      self.on_the_screen[i].lock_movement.right= false
      self.on_the_screen[i].lock_movement.left= true
    elseif npcRightSide>=playersLeftSide and playersLeftSide>=self.on_the_screen[i].p.x+10 then
      self.on_the_screen[i].lock_movement.left= false
      self.on_the_screen[i].lock_movement.right= true
    end
  else 
    self.on_the_screen[i].lock_movement.right= false
    self.on_the_screen[i].lock_movement.left= false
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
  self:drawBoss()
end

function NPCs:drawLifeBar(obj)
  local larguraDaBarra= 100
  local tamanhoDeUmPontoVida= (larguraDaBarra/obj.maximum_life)
  local tamanhoAtual= {
    w= tamanhoDeUmPontoVida*obj.life,
    h= 10
  }
  local bottom= obj.p.y-(obj.body.w/2)-10
  local top= bottom-tamanhoAtual.h
  local left= obj.p.x-(tamanhoAtual.w/2)-_G.map.cam.p.x
  local right= obj.p.x+(tamanhoAtual.w/2)-_G.map.cam.p.x
  local vertices= {
    left, top,
    right, top,
    right, bottom,
    left, bottom
  }
  love.graphics.setColor(1, 0, 0)
  love.graphics.polygon('fill', vertices)
  love.graphics.setColor(1, 1, 1)
  love.graphics.polygon('line', vertices)
end

function NPCs:drawBoss()
  self.boss:draw()
  self:drawLifeBar(self.boss)
  _G.collision:quadDraw(self.boss, _G.map.cam)
end

function NPCs:drawNPCs()
  for i=1, #self.on_the_screen do
    if self.on_the_screen[i]~=nil then
      self.on_the_screen[i]:draw(false)
      self:drawLifeBar(self.on_the_screen[i])
      _G.collision:quadDraw(self.on_the_screen[i], _G.map.cam)
    end
  end
end


return NPCs