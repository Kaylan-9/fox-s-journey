local Collision= {}
local metatable= {
  __call= function(self, new_collision, parent)
    local collision= {}
    collision.objs= new_collision.objs
    collision.parent= parent
    setmetatable(collision, {__index= self})
    return collision
  end
}

setmetatable(Collision, metatable)

function Collision:single(obj)
  local x_range= self.parent.physics:inside_the_area_of('x', obj)
  local y_range= self.parent.physics:inside_the_area_of('y', obj)

  if y_range and self.parent.trajectory.modified_position.x==false then
    local readjustmentToSimulateCollisionInX=function(next_actual_position)
      if (
        self.parent:getSide('right')<=obj:getSide('left') and
        self.parent:getSide('right', {x= next_actual_position})>=obj:getSide('left')
      ) then
        self.parent:setPosition('x', (obj:getSide('left')-(self.parent.body.w/2)))
        self.parent.trajectory:setModifiedPosition('x')
      elseif (
        self.parent:getSide('left')>=obj:getSide('right') and
        self.parent:getSide('left', {x= next_actual_position})<=obj:getSide('right')
      ) then
        self.parent:setPosition('x', (obj:getSide('right')+(self.parent.body.w/2)))
        self.parent.trajectory:setModifiedPosition('x')
      end
    end

    readjustmentToSimulateCollisionInX(self.parent.trajectory:getNextPosition('x'))
  end

  if x_range and self.parent.trajectory.modified_position.y==false then
    local readjustmentToSimulateCollisionInY=function(next_actual_position)

      if (
        self.parent:getSide('bottom')<=obj:getSide('top') and
        self.parent:getSide('bottom', {y= next_actual_position})>obj:getSide('top')
      ) then
        self.parent.physics.drop_force_application_timer:start({function ()
          self.parent.physics.force_acc.y= mathK:around((self.parent.physics.force_acc.y>0 and -1 or 1)*self.parent.physics.force_acc.y*self.parent.physics.energy_preservation)
          --ignora se força acumulada de y é igual a 1
          self.parent.physics.force_acc.y= self.parent.physics.force_acc.y==1 and 0 or self.parent.physics.force_acc.y
          self.parent.can_jump= true
        end})

        self.parent:setPosition('y', obj:getSide('top')-(self.parent.body.h/2)-1)
        self.parent.trajectory:setModifiedPosition('y')
      elseif (
        (self.parent:getSide('top')>=obj:getSide('bottom') and
        self.parent:getSide('top', {y= next_actual_position})<obj:getSide('bottom'))
      ) then
        self.parent.physics.force_acc.y= 0
        self.parent:setPosition('y', obj:getSide('bottom')+(self.parent.body.h/2)+1)
        self.parent.trajectory:setModifiedPosition('y')
        self.parent.can_jump= false
      end
    end
    self.parent.trajectory:setNextPosition('y')
    readjustmentToSimulateCollisionInY(self.parent.trajectory:getNextPosition('y'))
  end
end

function Collision:execObjs(func)
  for _, obj in pairs(self.objs) do
    if self.id~=obj.id then
      func(self, obj)
    end
  end
end

function Collision:all()
  self:execObjs(self.single)
end

function Collision:update()
  self:all()
end

return Collision