local Enemy= require('models.enemy')
local metatable, Boss= {
  __index=Enemy,
  __call=function(self, boss)
    local option= _G.tbl:deepCopy(_G.options_npcs[boss.name])
    local obj= Enemy(option, boss.vel, {x= _G.map.dimensions.w-600, y= -100}, boss.messages, boss.speech_interruption, true)
    obj.goto_player= true
    obj.active= false
    setmetatable(obj, {__index= self})
    return obj
  end
}, {}

setmetatable(Boss, metatable)

function Boss:update()
  if self then
    self.acc= self.acc + (_G.dt * math.random(1, 5))
    self.mov= (_G.dt * self.vel * 100) -- o quanto se move
    self:updateParameters()
    self:calcYPositionReferences()
    self:chasePlayer()
    self:dying()
    if self.was_destroyed then goto continue end
    local pode_ser_hostil_e_atacado= (self.reached_the_player and not self:verSeExisteDialogoQueIterrompe() and #_G.balloon.messages==0)

    if pode_ser_hostil_e_atacado then
      self:attackPlayer()
      self:takesDamage()
    end
  end
  ::continue::
end

return Boss