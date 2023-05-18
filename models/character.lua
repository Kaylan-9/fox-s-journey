--declaração de variáveis, os valores são atribuidos respectivamente: local n1, n2= v1, v2

--função serve para criar um objeto genérico de um personagem: player ou NPCs

local Tileset= require('models.tileset')
local Character, metatable= {}, {
  __call= function(self, option_props, vel, p, observadoPelaCamera, tileset, messages, speech_interruption) --self permite acessar os atributos de uma instância de uma classe
    local obj= {} --objeto para armazenar os futuros atributos de uma classe
    obj.name= option_props.name
    obj.s= option_props.s
    obj.tileset= Tileset('assets/graphics/'..options_tileset[tileset].imgname, options_tileset[tileset].n, options_tileset[tileset].adjustment)
    obj.frame_positions= option_props.frame_positions
    obj.hostile= option_props.hostile --{attack_frame, damage}
    if option_props.body~=nil then obj.body= option_props.body end -- {w,h}
    if option_props.direction~=nil then obj.direction= option_props.direction end
    if messages~=nil then obj.messages= messages end
    obj.vel= vel
    obj.max_vel= vel*2
    obj.angle= math.rad(0)
    obj.frame= 1
    obj.hold_animation= false
    obj.previous_animation= {}
    obj.animation= ''
    obj.acc= 0
    obj.maximum_life= 5
    obj.life= obj.maximum_life
    obj.freq_frames= 0.45
    obj.p= p
    obj.p.i= {y=-100}
    obj.p.f= {y=-100}
    obj.new_y= 0
    obj.observadoPelaCamera= observadoPelaCamera 
    obj.audio_em_tantos_s= 2
    obj.speech_interruption= speech_interruption
    setmetatable(obj, {__index= self}) -- relacionar os atributos da classe com a metatable
    obj:loadAudio()
    obj:resetTempoAudio()
    return obj
  end
}

setmetatable(Character, metatable)

function Character:test()
  print('character -> '..self.name)
end 

function Character:resetTempoAudio()
  self.audio_sem_tocar_ha= 0
  self.fim_sem_audio_tempo= 0
  self.ini_sem_audio_tempo= 0
end

function Character:loadAudio()
  self.audios= {}
  for k, v in pairs(self.frame_positions) do
    if self.frame_positions[k].audio~=nil then
      self.audios[k]= love.audio.newSource('assets/audios/'..self.frame_positions[k].audio, 'static')
    end
  end
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
  if (self.animation~='' and alternar==nil) or (self.animation~='' and alternar) then
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
      if self.frame_positions[self.animation].until_finished==true then
        self.previous_animation= self.frame_positions[self.animation]
        self.hold_animation= (self.frame<self.frame_positions[self.animation].f-1 and self.frame>=self.frame_positions[self.animation].i)
      -- Espera animação
      elseif self.previous_animation.until_finished==true and self.hold_animation==true then
        self.hold_animation= (self.frame<self.previous_animation.f-1 and self.frame>=self.previous_animation.i)
      end

    end
  else 
    self.frame= 1
  end
end

return Character
