-- {x= _G.map.dimensions.w-600, y= -100}


local Character= require('models.character')
local metatable, Enemy= {
  __index=Character,
  __call=function(self, option_props, running_speed, starting_position, messages, speech_interruption, goto_player)
    --tileset recebe o nome de option_props pois eles são iguais, ou seja menos um argumento
    local obj= Character(option_props, running_speed, starting_position, false, option_props.name, messages, speech_interruption)
    obj.goto_player= goto_player
    obj.lock_movement= {
      left= false, 
      right= false
    }
    setmetatable(obj, {__index= self})
    return obj
  end
}, {}

setmetatable(Enemy, metatable)

-- como possui a função de executar a morte de um NPC, a função tem que remover diretamente da lista de NPCs, por isso que o método pertence a classe NPCs
function Enemy:dying()
  if math.floor(self.life)==0 then 
    self.animation= 'dying'
    if not self.audios.dying:isPlaying() then self.audios.dying:play() end
    self.goto_player= false
    if self.frame==self.frame_positions['dying'].f then
      if self.acc>=(self.freq_frames) then
        self:destroy()
      end
    else  
      self:defaultUpdateFrame() 
    end
  end 
end


function Enemy:drawLifeBar()
  local larguraDaBarra= 100
  local tamanhoDeUmPontoVida= (larguraDaBarra/self.maximum_life)
  local tamanhoAtual= {
    w= tamanhoDeUmPontoVida*self.life,
    h= 10
  }
  local bottom= self.p.y-(self.body.w/2)-10
  local top= bottom-tamanhoAtual.h
  local left= self.p.x-(tamanhoAtual.w/2)-_G.map.cam.p.x
  local right= self.p.x+(tamanhoAtual.w/2)-_G.map.cam.p.x
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

function Enemy:chasePlayer()
  local left= (self.p.x-(self.body.w/2)-1)-_G.map.cam.p.x
  local right= (self.p.x+(self.body.w/2)+1)-_G.map.cam.p.x

  local playersLeftSide= _G.player.p.x-(_G.player.body.w/2)
  local playersRightSide= _G.player.p.x+(_G.player.body.w/2)

  if (left>playersRightSide) and self.goto_player then
    self.animation= 'walking'
    self:defaultUpdateFrame()
    self.s.x= -math.abs(self.s.x)*self.direction
    self.p.x= (self.p.x - self.mov)
    self.reached_the_player= false
  elseif (right<playersLeftSide) and self.goto_player then
    self.animation= 'walking'
    self:defaultUpdateFrame()
    self.s.x= math.abs(self.s.x)*self.direction
    self.p.x= (self.p.x + self.mov)
    self.reached_the_player= false
  else 
    self.reached_the_player= true
  end
end

function Enemy:attackPlayer()
  if self.hostile then
    self.animation= 'attacking'
    self:dealsDamage()
    self:defaultUpdateFrame()  
    -- expressão de raiva
    _G.player.expression.frame= 3
  end
end 

function Enemy:takesDamage()
  if _G.collision:ellipse(_G.player.p, self.p, (self.body.w/2), (self.body.h/2), (self.body.w/2)) then
    if type(_G.player.hostile.attack_frame)=='table' then
      for j=1, #_G.player.hostile.attack_frame do
        if _G.player.frame==_G.player.hostile.attack_frame[j] then
          if _G.player.acc>=_G.player.freq_frames then
            if self.life > 0 then
              self.life= self.life - _G.player.hostile.damage
            end
          end
        end 
      end
    end
  end
end


function Enemy:dealsDamage()  
  if _G.collision:ellipse(_G.player.p, self.p, (self.body.w/2), (self.body.h/2), (self.body.w/2)) then
    -- quando o frame troca o dano é aplicado
    if self.acc>=(self.freq_frames) and self.hostile.attack_frame==self.frame then
      if math.ceil((_G.player.life*#_G.displayers.props_lifeBar.tileset.tiles)/_G.player.maximum_life)>1 then 
        _G.player.life= _G.player.life-self.hostile.damage
      end 
    end
  end
end

function Enemy:verSeExisteDialogoQueIterrompe()
  if self.speech_interruption then
    _G.balloon.messages= self.messages
    self.speech_interruption= false
    return true 
  end
  return false
end

function Enemy:calcYPositionReferences()
  if self.p.f.y==-100 then self.p.y= self.new_y end
end

function Enemy:iniciarDialogo(key)
  if key=='f' then 
    local pode_iniciar_dialogo= (#balloon.messages==0 and self.reached_the_player)
    if pode_iniciar_dialogo then 
      _G.balloon.messages= self.messages
    else
      if _G.balloon.i<#balloon.messages then _G.balloon.i= _G.balloon.i+1
      else 
        _G.balloon.messages= {}
        _G.balloon.i= 1
      end
    end
  end
end

return Enemy