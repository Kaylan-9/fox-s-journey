local NPC= require('models.character.npc')
local metatable, Enemy= {
  __index= NPC,
  __call=function(self, option_props, running_speed, starting_position, messages, speech_interruption, goto_player)
    --tileset recebe o nome de option_props pois eles são iguais, ou seja menos um argumento
    local obj= NPC(option_props, running_speed, starting_position, false, option_props.name, messages, speech_interruption, goto_player)
    obj.active= false
    setmetatable(obj, {__index= self})
    return obj
  end
}, {}

setmetatable(Enemy, metatable)

-- como possui a função de executar a morte de um NPC, a função tem que remover diretamente da lista de NPCs, por isso que o método pertence a classe NPCs
function Enemy:dying()
  if math.floor(self.life)==0 then 
    -- pula_anim indica se a animação será pulada
    self.goto_player= false
    local pula_anim = not self:temAnim('dying')

    if not pula_anim then
      if not self.audios.dying:isPlaying() then self.audios.dying:play() end
      if self.frame==self.frame_positions['dying'].f then
        if self.frame_acc>=(self.freq_frames) then
          self:destroy()
        end
      else  
        self:defaultUpdateFrame() 
      end
    else
      self:destroy()
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
  local left= self.p.x-(tamanhoAtual.w/2)-_G.cam.p.x
  local right= self.p.x+(tamanhoAtual.w/2)-_G.cam.p.x
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

function Enemy:attackPlayer()
  if self.hostile then
    local pula_anim= not self:temAnim('attacking')
    self:dealsDamage(pula_anim)
    self:defaultUpdateFrame()  
  end
end 

function Enemy:takesDamage()
  if not _G.player.was_destroyed then
    if _G.collision:ellipse(_G.player.p, self.p, (self.body.w/2), (self.body.h/2), (self.body.w/2)) then
      if type(_G.player.hostile.attack_frame)=='table' then
        for j=1, #_G.player.hostile.attack_frame do
          if _G.player.frame==_G.player.hostile.attack_frame[j] then
            if _G.player.frame_acc>=_G.player.freq_frames then
              _G.player.audios['attacking']:play()
              if self.life > 0 then
                self.life= self.life - _G.player.hostile.damage
              end
            end
          end 
        end
      end
    end
  end
end


function Enemy:dealsDamage(pula_anim)  
  if not _G.player.was_destroyed and not pula_anim then
    if _G.collision:ellipse(_G.player.p, self.p, (self.body.w/2), (self.body.h/2), (self.body.w/2)) then
      -- quando o frame troca o dano é aplicado
      if self.frame_acc>=(self.freq_frames) and self.hostile.attack_frame==self.frame then
        if math.ceil((_G.player.life*#_G.displayers.props_lifeBar.tileset.tiles)/_G.player.maximum_life)>1 then 
          _G.player.life= _G.player.life-self.hostile.damage
        end 
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
  local posiciona_no_chao= not type(self.flight_direction)=='string' or self.flight_direction==nil
  if posiciona_no_chao then
    if self.p.f.y==-100 then self.p.y= self.y_from_the_current_floor end
  end 
end

function Enemy:iniciarDialogo(key, scancode, isrepeat)
  if key=='f' then 
    local pode_iniciar_dialogo= (#_G.balloon.messages==0)

    if self.reached_the_player then
      if pode_iniciar_dialogo then 
        _G.balloon.messages= self.messages
      else
        if _G.balloon.indice>=#_G.balloon.messages then 
          _G.balloon.indice= 1
          _G.balloon.messages= {}
        else
          _G.balloon.indice= _G.balloon.indice + 1
        end
      end
    end 
    
  end
end

return Enemy