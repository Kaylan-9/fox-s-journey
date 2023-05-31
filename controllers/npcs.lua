local Enemy= require('models.enemy')

local NPCs, metatable= {}, {
  __call= function(self, npcs)
    local obj= {}
    obj.on_the_screen= {} --cada tabela é um personagem em cena
    obj.number_of_dead= 0 -- para usado depois
    setmetatable(obj, {__index= self})
    obj:load(npcs)
    return obj
  end
}

setmetatable(NPCs, metatable)

-- incia quando o jogo incia, mas pode ser utilizado para resetar os NPCs, por exemplo ao iir para a próxima fase 
function NPCs:load(npcs)
  for i=1, #npcs do self:create(npcs[i].name, npcs[i].vel, npcs[i].p, npcs[i].messages, npcs[i].speech_interruption, npcs[i].goto_player) end
end

function NPCs:create(optioname, running_speed, starting_position, messages, speech_interruption, goto_player)
  if type(options_npcs[optioname])=='table' then
    local option= _G.tbl:deepCopy(options_npcs[optioname])
    local new_enemy= Enemy(option, running_speed, starting_position, messages, speech_interruption, goto_player)
    table.insert(self.on_the_screen, new_enemy)
  end
end 

-- a função abaixo serve para controlar os valores correspondentes aos NPCs, como em que momento o player pode iniciar uma conversasão ou não, e também controla por exemplo até quando o esqueleto se movimentara e também a execução de sua animação
function NPCs:update()
  for i=1, #self.on_the_screen do
    if self.on_the_screen[i] then
      self.on_the_screen[i].acc= self.on_the_screen[i].acc + (_G.dt * math.random(1, 5))
      self.on_the_screen[i].mov= (_G.dt * self.on_the_screen[i].vel * 100) -- o quanto se move
      self.on_the_screen[i]:updateParameters()
      self.on_the_screen[i]:calcYPositionReferences()
      if self.on_the_screen[i]:playerVisible() then self.on_the_screen[i]:chasePlayer() end
      self.on_the_screen[i]:dying()
      if self.on_the_screen[i].was_destroyed then goto continue end
      local pode_ser_hostil_e_atacado= (self.on_the_screen[i].reached_the_player and not self.on_the_screen[i]:verSeExisteDialogoQueIterrompe() and #_G.balloon.messages==0)

      if pode_ser_hostil_e_atacado then
        self.on_the_screen[i]:attackPlayer()
        self.on_the_screen[i]:takesDamage()
      end
    end
    ::continue::
  end
  

  self:removeMortos()
end

function NPCs:pauseAudios()
  for i=1, #self.on_the_screen do
    self.on_the_screen[i]:pauseAudios()
  end
end

function NPCs:keypressed(key, scancode, isrepeat)
  for i=1, #self.on_the_screen do
    self.on_the_screen[i]:iniciarDialogo(key, scancode, isrepeat)
  end
end

function NPCs:removeMortos()
  local count_empty_death_rate= 0 
  for i=1, #self.on_the_screen do
    if self.on_the_screen[i-count_empty_death_rate].was_destroyed then 
      self.number_of_dead= self.number_of_dead + 1
      table.remove(self.on_the_screen, i-count_empty_death_rate)
      count_empty_death_rate= count_empty_death_rate + 1
    end
  end 
end

function NPCs:draw() 
  for i=1, #self.on_the_screen do
    self.on_the_screen[i]:draw()
    self.on_the_screen[i]:drawLifeBar()
    _G.collision:quadDraw(self.on_the_screen[i], _G.cam)
  end
end

return NPCs

--[[
& Em construção
Esse mecânismo serve para a função impedirMovimentaçãoPlayer, invés de subtrair a soma de movimentação do player na horizontal é melhor travar a sua posição com base em uma propriedade para cada NPC
function NPCs:naoPermiteSeMoverPara(direcao)
  local pode= false
  for i=1, #self.on_the_screen do
    if self.on_the_screen-count_empty_death_rate].lock_movement[direcao] then
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

  local collisao= collision:quad(self.on_the_screen[i], _G.player, _G.cam)
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
]]
