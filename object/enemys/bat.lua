local tilesManager= require('manager.tilesManager')
local Enemy= require('object.enemy')
local EnemyBat= {}
local metatable= {
  __index= Enemy,
  __call= function(self, objectManager, initial_position)
    local enemyBat= Enemy(objectManager, initial_position, -1, tilesManager:get('bat'))
    setmetatable(enemyBat, {__index= self})
    return enemyBat
  end
}

setmetatable(EnemyBat, metatable)

function EnemyBat:loadAnimationSettings()
  self.animate:createAnimation('flying', 'normal', {i=1, f=6})
end

function Enemy:update()
  self:controlling()
  self:flying()
  self:updateObjectBehavior()
end

function Enemy:running()
  self.trajectory.current_walking_speed= (KeyboardMouseManager:getKeyUsed('run') and self.trajectory.walking_speed.max or self.trajectory.walking_speed.min)
end
function Enemy:walking()
  if KeyboardMouseManager:getKeyUsed('left') or KeyboardMouseManager:getKeyUsed('right') then self.animate:setAnimation('walking')
  elseif KeyboardMouseManager:getKeyUsed('run') then self.animate:setAnimation('running')
  end
  if KeyboardMouseManager:getKeyUsed('left') then
    self:setPoint('left')
    self.trajectory:setCurrentMovement('x' ,-self.trajectory.current_walking_speed*dt*100)
  elseif KeyboardMouseManager:getKeyUsed('right') then
    self:setPoint('right')
    self.trajectory:setCurrentMovement('x', self.trajectory.current_walking_speed*dt*100)
  end
end

return EnemyBat