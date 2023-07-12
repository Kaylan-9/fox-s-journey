local tilesManager= require('manager.tilesManager')
local Obj= require('obj.obj')
local Block= {}
local metatable= {
  __index= Obj,
  __call= function(self, new_blk)
    -- new_blk contém: objManager, initial_position, p_reference, move_every
    local block= Obj(
      new_blk.objManager,
      {
        name= 'block',
        right_edge_image= 1,
        scale_factor= {x= 2, y= 2},
      },
      {
        w= 64,
        h= 64
      },
      new_blk.initial_position, new_blk.p_reference, new_blk.move_every,
      {
        static_frame= 41,
        tileset= tilesManager:get('map'),
      },
      {
        energy_preservation= 0,
        mass= 10.5,
        fixed= true,
        objs= new_blk.objManager:getList({}),
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
  self:updateObjBehavior()
end

return Block