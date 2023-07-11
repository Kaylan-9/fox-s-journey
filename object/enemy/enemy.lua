local Object= require('object.object')

local Enemy= {}
local metatable= {
  __index= Object,
  __call= function(self, objectManager, initial_position, p_reference, right_edge_image, tileset, walking_speed)
    local enemy= Object(
      objectManager,
      {
        name= 'enemy',
        right_edge_image= right_edge_image,
        scale_factor= {x= 2, y= 2},
      },
      {
        w= 32,
        h= 50
      },
      initial_position,
      p_reference,
      {x=0.5, y=0.25},
      {
        static_frame= 1,
        tileset= tileset
      },
      {
        energy_preservation= 0.44,
        mass= 3.5,
        fixed= false,
        objects= objectManager:getList({})
      },
      {
        walking_speed= walking_speed,
      }
    )
    enemy.does_not_go_through_bottomless_holes= true
    setmetatable(enemy, {__index= self})
    return enemy
  end
}

setmetatable(Enemy, metatable)

return Enemy