local Object= require('object.object')
local Fireball= require('object.props.lda.fireball')

local LongDistanceAttack= {}
local metatable= {
  __index= Object,
  __call=function(self, name, new_lda, owner)
    local long_distance_attack
    if name=='fireball' then long_distance_attack= Fireball(owner)
    end
    long_distance_attack.owner= owner
    long_distance_attack.timer= timer:new(new_lda.duration, false)
    if new_lda.effects_for_enemies then
      long_distance_attack.effects_for_enemies= new_lda.effects_for_enemies
    end
    setmetatable(long_distance_attack, {__index= self})
    return long_distance_attack
  end
}

setmetatable(LongDistanceAttack, metatable)

function LongDistanceAttack:update()
  local direction= self.scale_factor.x/self.scale_factor.x
  self.trajectory:setCurrentMovement('x', direction*self.trajectory.walking_speed.min*dt*100)
  self:updateObjectBehavior()
  self.timer:start()
  if self.timer:finish() then
    self.objectManager:removeObject(self.id)
  end

  -- if self.physics.force_acc.y>-6 then
  --   self.physics.force_acc.y= self.physics.force_acc.y-1
  -- end
end

return LongDistanceAttack