local tilesManager= require('manager.tilesManager')
local Enemy= require('obj.enemy.enemy')
local Obj= require('obj.obj')
local EnemyBat= {}
local metatable= {
  __index= Enemy,
  __call= function(self, objManager, initial_position, p_reference)
    local enemyBat= Enemy(objManager, initial_position, p_reference, -1, tilesManager:get('bat'), {min= 3, max= 15})
    setmetatable(enemyBat, {__index= self})
    enemyBat:loadAnimationSettings()
    return enemyBat
  end
}

setmetatable(EnemyBat, metatable)

function EnemyBat:load()
  if self.to_be_chased==nil then 
    self.to_be_chased= self.objManager:get('player')
  end 
end

function EnemyBat:loadAnimationSettings()
  self.animate:createAnimation('flying', 'normal', {i=1, f=5})
end

function EnemyBat:chasePlayer()
  if self:getSide('right')<self.to_be_chased:getSide('left') then
    self.must_chase_the_player=  true
    self:setPoint('right')
    self.trajectory:setCurrentMovement('x' ,self.trajectory.current_walking_speed*dt*100)
    self.animate:setAnimation('flying')
    return
  elseif self:getSide('left')>self.to_be_chased:getSide('right') then
    self.must_chase_the_player=  true
    self:setPoint('left')
    self.trajectory:setCurrentMovement('x' ,-self.trajectory.current_walking_speed*dt*100)
    self.animate:setAnimation('flying')
    return
  end
  self.must_chase_the_player=  false
end

function Enemy:update()
  self:chasePlayer()
  self:updateObjBehavior(self.must_chase_the_player)
end

return EnemyBat