local Screen= require('screen.screen')
local Global= {}
local metatable= {
  __index= Screen,
  __call= function(self, conditions)
    local global= Screen(conditions)
    setmetatable(global, {__index= self})
    global:loadActionSettings()
    return global
  end
}
setmetatable(Global, metatable)

function Global:loadActionSettings()
  self:addAction('close_game', 'escape', function() love.event.quit() end)
end

return Global
