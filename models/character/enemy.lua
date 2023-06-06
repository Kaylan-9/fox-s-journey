local NPC= require('models.character.npc')
local metatable, Enemy= {
  __index= NPC,
  __call=function(self, option_props, running_speed, starting_position, messages, speech_interruption, goto_player)
    --tileset recebe o nome de option_props pois eles são iguais, ou seja menos um argumento
    local obj= NPC(option_props, running_speed, starting_position, messages, speech_interruption, goto_player)
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
    self:dealsDamage(self:temAnim('attacking'))
    self:defaultUpdateFrame()  
  end
end 

-- método que verifica se o inimigo foi atacado
function Enemy:takesDamage()
  if not _G.player.was_destroyed then
    if _G.collision:ellipse(_G.player.p, self.p, (self.body.w/2), (self.body.h/2), (self.body.w/2)) then
      if type(_G.player.hostile.attack_frame)=='table' then
        for j=1, #_G.player.hostile.attack_frame do
          if _G.player.frame==_G.player.hostile.attack_frame[j] then
            if _G.player.frame_acc>=_G.player.freq_frames then
              _G.player.audios['attacking']:play()
              if self.life > 0 then
                
                if self.type=='flying' then  -- marca se o inimigo do tipo flying foi atacado 
                  self.recently_attacked:start()  -- inicia timer de 9 segundos para que o inimigo não ataque e se afaste
                  self.center_radius= self.p.x+((self.s.x>0 and 1 or -1)*150) -- define a distância até onde o inimigo deve se afastar, valor de distância constante
                end

                self.life= self.life - _G.player.hostile.damage
              end
            end
          end 
        end
      end
    end
  end
end


function Enemy:dealsDamage()  
  if not _G.player.was_destroyed then
    if _G.collision:ellipse(_G.player.p, self.p, (self.body.w/2), (self.body.h/2), (self.body.w/2)) then
      
      local executed_attack_frame= false -- variável determina se o inimigo desenhou frame, ou um dos frames de ataque
      if type(self.hostile.attack_frame)=='table' then
        for j=1, #self.hostile.attack_frame do
          if self.hostile.attack_frame[j]==self.frame then
            executed_attack_frame= true 
            break
          end
        end
      elseif type(self.hostile.attack_frame)=='number' and self.hostile.attack_frame==self.frame then
        executed_attack_frame= true
      end
    -- quando o frame troca o dano é aplicado
      if self.frame_acc>=(self.freq_frames) and executed_attack_frame then
        _G.player.life= _G.player.life-self.hostile.damage
      end
    end
  end
end

function Enemy:calcYPositionReferences()
  local posiciona_no_chao= not type(self.flight_direction)=='string' or self.flight_direction==nil
  if posiciona_no_chao then
    if self.p.f.y==-100 then 
      if self.type=='walking' then
        self.p.y= self.y_from_the_current_floor 
      end
    end
  end 
end

return Enemy