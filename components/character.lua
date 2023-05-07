--declaração de variáveis, os valores são atribuidos respectivamente: local n1, n2= v1, v2

--função serve para criar um objeto genérico de um personagem: player ou NPCs

local Tileset= require('components.tileset')
local Character, metatable= {}, {
  __call= function(self, option_props, vel, p, messages, hostile, damage) --self permite acessar os atributos de uma instância de uma classe
    local object= {} --objeto para armazenar os futuros atributos de uma classe
    object.s= {x= 2.5, y= 2.5}
    object.angle= math.rad(0)
    object.frame= 1
    object.name= option_props.name
    object.frame_positions= option_props.frame_positions
    object.hold_animation= false
    object.previous_animation= {}
    object.animation= ''
    object.vel= vel
    object.acc= 0
    object.life= 8
    object.p= p
    object.p.i= {y=-100}
    object.p.f= {y=-100}
    object.hostile= hostile
    if damage~=nil then object.damage= damage end --{attack_frame, value}

    if option_props.body~=nil then object.body= option_props.body end -- {w,h}
    object.tileset= Tileset('assets/graphics/'..option_props.imgname, option_props.frame_n, option_props.adjustment)
    if option_props.direction~=nil then object.direction= option_props.direction end
    if messages~=nil then object.messages= messages end
    setmetatable(object, {__index= self}) -- relacionar os atributos da classe com a metatable
    return object
  end
}

setmetatable(Character, metatable)

return Character
