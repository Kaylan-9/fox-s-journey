--declaração de variáveis, os valores são atribuidos respectivamente: local n1, n2= v1, v2

local Tileset= require('components.tileset')
local Character, metatable= {}, {
  __call= function(self, option_props, vel, p) --self permite acessar os atributos de uma instância de uma classe
    local object= {} --objeto para armazenar os futuros atributos de uma classe
    object.s= {x= 2.5, y= 2.5}
    object.angle= 0
    object.frame= 1
    object.name= option_props.name
    object.frame_positions= option_props.frame_positions
    object.vel= vel
    object.acc= 0
    object.p= p
    object.p.i= {y=-100}
    object.p.f= {y=-100}
    object.tileset= Tileset('assets/graphics/'..option_props.imgname, option_props.frame_n, option_props.adjustment)
    setmetatable(object, {__index= self}) -- relacionar os atributos da classe com a metatable
    return object
  end
} 

setmetatable(Character, metatable)

return Character
