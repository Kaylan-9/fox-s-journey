local tilesManager= require('manager.tilesManager')
local Object= require('object.object')
local Block= {}
local metatable= {
  __index= Object,
  __call= function(self, name, objects, initial_position, p_reference)
    name= 'block'..((type(name)=='number' or type(name)=='string') and name or '')
    local block= Object(
      name,
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
        mass= 10.5,
        body= {
          w= 64,
          h= 64
        },
        fixed= true,
        objects= objects,
      },
      {
        walking_speed= {min= 5, max= 15},
      },
      p_reference
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