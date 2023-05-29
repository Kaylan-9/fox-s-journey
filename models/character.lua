--declaração de variáveis, os valores são atribuidos respectivamente: local n1, n2= v1, v2

--função serve para criar um objeto genérico de um personagem: player ou NPCs

local Tileset= require('models.tileset')
local Character, metatable= {}, {
  __call= function(self, option_props, running_speed, starting_position, observadoPelaCamera, tileset, messages, speech_interruption) --self permite acessar os atributos de uma instância de uma classe
    local obj= option_props
    obj.observadoPelaCamera= observadoPelaCamera 
    obj.tileset= Tileset('assets/graphics/'..options_tileset[tileset].imgname, options_tileset[tileset].n, options_tileset[tileset].adjustment)
    setmetatable(obj, {__index= self}) -- relacionar os atributos da classe com a metatable
    obj:setAnimProps()
    obj:setAudioProps()
    obj:setPositionProps(starting_position)
    obj:setLimitersProps(running_speed)
    obj:setDialogueProps(speech_interruption, messages)
    return obj
  end
}

setmetatable(Character, metatable)

function Character:setAnimProps()
  self.frame= 1
  self.freq_frames= 0.45
  self.hold_animation= false
  self.previous_animation= {}
  self.animation= ''
  self.acc= 0
end

function Character:setAudioProps()
  self.timer_sem_tocar_audio_ha= _G.timer:new(2)
  self:loadAudios()
end

function Character:loadAudios()
  self.audios= {}
  for k, v in pairs(self.frame_positions) do
    if self.frame_positions[k].audio~=nil then
      self.audios[k]= love.audio.newSource('assets/audios/'..self.frame_positions[k].audio, 'static')
    end
  end
end

function Character:setPositionProps(starting_position)
  self.p= starting_position
  self.p.i= {y=-100}
  self.p.f= {y=-100}
  self.new_y= 0
end

function Character:setLimitersProps(running_speed)
  self.vel= running_speed
  self.max_vel= self.vel*2
  self.maximum_life= 5
  self.life= self.maximum_life
  self.angle= math.rad(0)
end

function Character:setDialogueProps(speech_interruption, messages)
  self.speech_interruption= speech_interruption or false
  self.messages= messages or {} -- objeto pode ser vazio
end


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

function Character:destroy()
  for k, v in pairs(self) do
    self[k] = nil
  end
  setmetatable(self, nil)
  self.was_destroyed= true
end


function Character:calcNewFloorPosition()
  local imaginary_px= self.observadoPelaCamera and _G.map.cam.p.x+self.p.x or self.p.x
  self.new_y= _G.map:positionCharacter(
    self.p, 
    imaginary_px,
    self.tileset.tileSize.h, 
    self.s.x
  ).y
end

-- terá que ser chamado em todo update para funcionar
function Character:updateParameters()
  self:calcNewFloorPosition()
end

function Character:draw()
  local x= self.observadoPelaCamera and self.p.x or self.p.x-_G.map.cam.p.x
  love.graphics.draw(
    self.tileset.obj,
    self.tileset.tiles[self.frame],
    x,
    self.p.y,
    self.angle,
    self.s.x,
    self.s.y,
    self.tileset.tileSize.w/2, 
    self.tileset.tileSize.h/2
  )
end

function Character:getSide(direction)
  local movimento_de_camera= self.observadoPelaCamera and 0 or _G.map.cam.p.x
  return self.p.x+(direction=='left' and -(self.body.w/2) or (self.body.w/2))-movimento_de_camera
end

function Character:defaultUpdateFrame(alternar)
  if self.animation~='' and (alternar==nil or alternar or self.frame_positions[self.animation].type=='infinite') then
    if self.acc>=(self.freq_frames) then
      self.frame= self.frame + 1
      self.acc= 0

      -- A primeira estrutura condicional serve para recomeçar uma animação, após f ele recomeça a animação no frame i
      -- hold_animation é uma propriedade que serve para travar de um frame a outro até a animação anterior chegar ao seu f
      if self.hold_animation==false then
        if
          (self.frame<self.frame_positions[self.animation].i or
          self.frame>self.frame_positions[self.animation].f)
        then
          self.frame= self.frame_positions[self.animation].i
        end
      end

      --- Se a animação não é travada significa que ela está iniciando uma nova animação, essa estrutura basicamente a função de travar animação se ela está no primeiro frame, e quando ele chegar no último ela será destravada
      if self.frame_positions[self.animation].type=="until_finished" then
        self.previous_animation= self.frame_positions[self.animation]
        self.hold_animation= (self.frame<self.frame_positions[self.animation].f-1 and self.frame>=self.frame_positions[self.animation].i)
      -- Espera animação
      elseif self.previous_animation.type=="until_finished" and self.hold_animation==true then
        self.hold_animation= (self.frame<self.previous_animation.f-1 and self.frame>=self.previous_animation.i)
      end

    end
  else 
    self.frame= 1
  end
end

return Character
