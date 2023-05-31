local menu= require('controllers.screens.menu')
local gameover= require('controllers.screens.gameover')
local Screens= {
  objs= {
    menu, 
    gameover
  }
}

function Screens:load()
  for k, _ in pairs(self.objs) do
    self.objs[k]:load()
  end
end

function Screens:update()
  for k, _ in pairs(self.objs) do
    self.objs[k]:update()
  end
end

function Screens:draw()
  for k, _ in pairs(self.objs) do
    self.objs[k]:draw()
  end
end

return Screens