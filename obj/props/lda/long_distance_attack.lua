local Obj= require('obj.obj')
local Fireball= require('obj.props.lda.fireball')

local LongDistanceAttack= {}
local metatable= {
  __index= Obj,
  __call=function(self, name, new_lda, owner)
    local long_distance_attack
    if name=='fireball' then long_distance_attack= Fireball(owner)
    end
    long_distance_attack.owner= owner
    long_distance_attack.timer= timer:new({
      duration= new_lda.duration,
      can_repeat= true,
      parent= self
    })
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
  self:updateObjBehavior()
  self.timer:start()
  if self.timer:finish() then
    self.objManager:removeObj(self.id)
  end
  self:jumping()
end

function LongDistanceAttack:jumping()
  if self.physics.force_acc.y>-6 then
    self.physics.force_acc.y= self.physics.force_acc.y-1
  end 
end

return LongDistanceAttack