local CameraManager= require('manager.cameraManager')
local Object= require('object.object')
local Enemy= {}
local metatable= {
  __index= Object,
  __call= function(self, objectManager, initial_position, right_edge_image, tileset)
    local enemy= Object(
      objectManager,
      {
        name= 'enemy',
        right_edge_image= right_edge_image,
        scale_factor= {x= 2, y= 2},
      },
      {
        w= 32,
        h= 55
      },
      initial_position,
      CameraManager:getPosition(),
      {x=0.5, y=0.25},
      {
        static_frame= 1,
        tileset= tileset
      },
      {
        energy_preservation= 0.44,
        mass= 3.5,
        fixed= false,
        objects= objectManager:getList('objects')
      },
      {
        walking_speed= {min= 8, max= 18},
      }
    )
    enemy.ranged_attack_timer= timer:new(0.1, false)
    setmetatable(enemy, {__index= self})
    enemy:loadAnimationSettings()
    return enemy
  end
}

setmetatable(Enemy, metatable)

return Enemy