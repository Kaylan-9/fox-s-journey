--declaração de variáveis, os valores são atribuidos respectivamente: local n1, n2= v1, v2

--função serve para criar um objeto genérico de um personagem: player ou NPCs

local Tileset= require('models.tileset')
local Character, metatable= {}, {
  __call= function(self, option_props, vel, p, messages) --self permite acessar os atributos de uma instância de uma classe
    local object= {} --objeto para armazenar os futuros atributos de uma classe
    object.name= option_props.name
    object.s= option_props.s
    object.tileset= Tileset('assets/graphics/'..option_props.imgname, option_props.frame_n, option_props.adjustment)
    object.frame_positions= option_props.frame_positions
    object.hostile= option_props.hostile --{attack_frame, damage}
    if option_props.body~=nil then object.body= option_props.body end -- {w,h}
    if option_props.direction~=nil then object.direction= option_props.direction end
    if messages~=nil then object.messages= messages end
    object.vel= vel
    object.max_vel= vel*2
    object.angle= math.rad(0)
    object.frame= 1
    object.hold_animation= false
    object.previous_animation= {}
    object.animation= ''
    object.acc= 0
    object.maximum_life= 5
    object.life= object.maximum_life
    object.freq_frames= 0.45
    object.p= p
    object.p.i= {y=-100}
    object.p.f= {y=-100}
    object.new_y= 0
    setmetatable(object, {__index= self}) -- relacionar os atributos da classe com a metatable
    return object
  end
}

setmetatable(Character, metatable)

function Character:test()
  print('character -> '..self.name)
end 

function Character:calcNewFloorPosition(observadoPelaCamera)
  local imaginary_px= observadoPelaCamera and _G.map.cam.p.x+self.p.x or self.p.x
  self.new_y= _G.map:positionCharacter(
    self.p, 
    imaginary_px,
    self.tileset.tileSize.h, 
    self.s.x
  ).y
end

-- terá que ser chamado em todo update para funcionar
function Character:updateParameters(observadoPelaCamera)
  self:calcNewFloorPosition(observadoPelaCamera)
end

function Character:draw(observadoPelaCamera)
  local x= observadoPelaCamera and self.p.x or self.p.x-_G.map.cam.p.x
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
      elseif self.previous_animation.until_finished==true and self.hold_animation==true then
        self.hold_animation= (self.frame<self.previous_animation.f-1 and self.frame>=self.previous_animation.i)
      end

    end
  else 
    self.frame= 1
  end
end

return Character
