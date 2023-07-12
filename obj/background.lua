local tilesManager= require('manager.tilesManager')
local Obj= require('obj.obj')
local Background= {}
local metatable= {
  __index= Obj,
  __call= function(self, new_bg)
    -- new_bg contém: objManager, name_img, p_reference, move_every
    local background= Obj(
      new_bg.objManager,
      {
        name= 'background',
        right_edge_image= 1,
        scale_factor= {x= 7, y= 7},
      },
      nil,
      {
        x= love.graphics.getWidth()/2,
        y= love.graphics.getHeight()/2
      },
      new_bg.p_reference,
      new_bg.move_every,
      love.graphics.newImage('assets/graphics/background/'.. new_bg.name_img..'.png')
    )
    setmetatable(background, {__index= self})
    return background
  end
}
setmetatable(Background, metatable)

function Background:update() end

return Background