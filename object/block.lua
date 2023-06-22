local tilesManager= require('manager.tilesManager')
local Object= require('object.object')
local Block= {}
local metatable= {
  __index= Object,
  __call= function(self, objects, initial_position)
    local block= Object(
      {
        right_edge_image= 1,
        scale_factor= {x= 2, y= 2},
        initial_position= initial_position
      },
      {
        static_frame= 41,
        tileset= tilesManager:get('map'),
      },
      {
        energy_preservation= 0,
        mass= 1.5,
        body= {
          w= 64,
          h= 64
        },
        fixed= true,
        objects= objects,
      },
      {
        walking_speed= {min= 5, max= 15},
      }
    )
    setmetatable(block, {__index= self})
    return block
  end
}
setmetatable(Block, metatable)

function Block:update()
  self:updateObjectBehavior()
end

return Block