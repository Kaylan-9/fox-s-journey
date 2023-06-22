local Screen= {}
local metatable= {
  __call= function(self, conditions)
    local screen= {}
    screen.actions= {}
    screen.conditions= conditions
    setmetatable(screen, {__index= self})
    return screen
  end
}
setmetatable(Screen, metatable)

function Screen:addAction(name_action, key, func)
  self.actions[name_action]= function(current_key)
    if current_key==key then func() end
  end
end

function Screen:keypressed(key)
  if self.conditions then
    for _, func in pairs(self.actions) do
      func(key)
    end
  end
end

return Screen