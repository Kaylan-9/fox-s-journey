local tilesManager= require('manager.tilesManager')
local Enemy= require('object.enemy.enemy')
local Object= require('object.object')
local EnemyBat= {}
local metatable= {
  __index= Enemy,
  __call= function(self, objectManager, initial_position, p_reference)
    local enemyBat= Enemy(objectManager, initial_position, p_reference, -1, tilesManager:get('bat'), {min= 3, max= 15})
    enemyBat.must_chase_the_player= false
    setmetatable(enemyBat, {__index= self})
    enemyBat:loadAnimationSettings()
    return enemyBat
  end
}

setmetatable(EnemyBat, metatable)

function EnemyBat:load()
  if self.to_be_chased==nil then 
    self.to_be_chased= self.objectManager:get('player')
  end 
end

function EnemyBat:loadAnimationSettings()
  self.animate:createAnimation('flying', 'normal', {i=1, f=6})
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
  self:updateObjectBehavior(self.must_chase_the_player)
end

return EnemyBat