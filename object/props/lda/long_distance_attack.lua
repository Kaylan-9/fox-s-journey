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
    if new_lda then
      long_distance_attack.duration= new_lda.duration
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
end

return LongDistanceAttack