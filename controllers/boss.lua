local Enemy= require('enemy.character')
local metatable, Boss= {
  __index=Enemy,
  __call=function(self, boss)
    local obj= Enemy(_G.options_npcs[boss.name], self.vel, {x= _G.map.dimensions.w-600, y= -100} , false, boss.name, boss.messages)
    obj.goto_player= true
    obj.active= false
    setmetatable(obj, {__index= self})
    return obj
  end
}, {}

setmetatable(Boss, metatable)

return Boss