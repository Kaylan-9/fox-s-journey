local tilesManager= require('manager.tilesManager')
local Object= require('object.object')
local Background= {}
local metatable= {
  __index= Object,
  __call= function(self, new_bg)
    -- new_bg contém: objectManager, name_img, p_reference, move_every
    local background= Object(
      new_bg.objectManager,
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