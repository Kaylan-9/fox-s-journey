local tilesManager= require('manager.tilesManager')
local Object= require('object.object')
local Background= {}
local metatable= {
  __index= Object,
  __call= function(self)
    local background= Object(
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
      nil,
      nil,
      love.graphics.newImage('assets/graphics/background.png')
    )
    setmetatable(background, {__index= self})
    return background
  end
}
setmetatable(Background, metatable)

function Background:update() end

return Background