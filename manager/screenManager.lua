local Global= require('screen.global')
local ScreenManager= {
  screens= {}
}

function ScreenManager:add(screen)
  table.insert(self.screens, screen)
end
function ScreenManager:load()
  self:add(Global(true))
end

function ScreenManager:keypressed(key)
  for _, screen in pairs(self.screens) do
    screen:keypressed(key)
  end
end

return ScreenManager