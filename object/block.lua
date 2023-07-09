local tilesManager= require('manager.tilesManager')
local Object= require('object.object')
local Block= {}
local metatable= {
  __index= Object,
  __call= function(self, objectManager, initial_position, p_reference, move_every)
    local block= Object(
      objectManager,
      {
        name= 'block',
        right_edge_image= 1,
        scale_factor= {x= 2, y= 2},
      },
      {
        w= 64,
        h= 64
      },
      initial_position, p_reference, move_every,
      {
        static_frame= 41,
        tileset= tilesManager:get('map'),
      },
      {
        energy_preservation= 0,
        mass= 10.5,
        fixed= true,
        objects= objectManager:getList('objects'),
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