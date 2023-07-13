local Collision= function(self, parent)
  local collision= self
  collision.parent= parent

  function collision:single(obj)
    local x_range= self.physics:inside_the_area_of('x', obj)
    local y_range= self.physics:inside_the_area_of('y', obj)
  
    if y_range and self.trajectory.modified_position.x==false then
      local readjustmentToSimulateCollisionInX=function(next_actual_position)
        if (
          self:getSide('right')<=obj:getSide('left') and
          self:getSide('right', {x= next_actual_position})>=obj:getSide('left')
        ) then
          self:setPosition('x', (obj:getSide('left')-(self.body.w/2)))
          self.trajectory:setModifiedPosition('x')
        elseif (
          self:getSide('left')>=obj:getSide('right') and
          self:getSide('left', {x= next_actual_position})<=obj:getSide('right')
        ) then
          self:setPosition('x', (obj:getSide('right')+(self.body.w/2)))
          self.trajectory:setModifiedPosition('x')
        end
      end
  
      readjustmentToSimulateCollisionInX(self.trajectory:getNextPosition('x'))
    end
  
    if x_range and self.trajectory.modified_position.y==false then
      local readjustmentToSimulateCollisionInY=function(next_actual_position)
  
        if (
          self:getSide('bottom')<=obj:getSide('top') and
          self:getSide('bottom', {y= next_actual_position})>obj:getSide('top')
        ) then
          self.physics.drop_force_application_timer:start({function ()
            self.physics.force_acc.y= mathK:around((self.physics.force_acc.y>0 and -1 or 1)*self.physics.force_acc.y*self.physics.energy_preservation)
            --ignora se força acumulada de y é igual a 1
            self.physics.force_acc.y= self.physics.force_acc.y==1 and 0 or self.physics.force_acc.y
            self.can_jump= true
          end})
  
          self:setPosition('y', obj:getSide('top')-(self.body.h/2)-1)
          self.trajectory:setModifiedPosition('y')
        elseif (
          (self:getSide('top')>=obj:getSide('bottom') and
          self:getSide('top', {y= next_actual_position})<obj:getSide('bottom'))
        ) then
          self.physics.force_acc.y= 0
          self:setPosition('y', obj:getSide('bottom')+(self.body.h/2)+1)
          self.trajectory:setModifiedPosition('y')
          self.can_jump= false
        end
      end
      self.trajectory:setNextPosition('y')
      readjustmentToSimulateCollisionInY(self.trajectory:getNextPosition('y'))
    end
  end
  
  function collision:execObjsCollision(func)
    for _, obj in pairs(self.objs) do
      if self.id~=obj.id then
        func(self, obj)
      end
    end
  end
  
  function collision:all()
    self:execObjsCollision(self.single)
  end
  
  function collision:update()
    self:all()
  end
  
  setmetatable(collision, {
    __index= parent,
    __newindex= parent
  })

  return collision
end

return Collision