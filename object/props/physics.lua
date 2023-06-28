local Physics= {}
local metatable= {
  __call=function(self, new_physics, main_object)
    local physics= {}
    physics.fixed= new_physics.fixed
    physics.objects= new_physics.objects
    physics.mass= new_physics.mass
    physics.energy_preservation= new_physics.energy_preservation
    physics.force_acc= {
      y= 0,
      x= 0
    }
    physics.main_object= main_object
    setmetatable(physics, {__index= self})
    return physics
  end
}
setmetatable(Physics, metatable)

function Physics:update()
  self:collisions()
  if self.main_object.trajectory.modified_position.x==false then
    self.main_object:move('x', self.main_object.trajectory:getCurrentMovement('x'))
  end

  self.main_object.trajectory:resetModifiedPosition()
  self.main_object.trajectory:resetCurrentMovement()
  self.main_object.trajectory:resetNextPosition()
  self:aboveAndWithinTheRangeX(
    function(this, object)
      if object.physics then
        local meter_s= 2
        this.force_acc.y= this.force_acc.y + math.sqrt((meter_s*object.physics.mass)/(object:realPosition().y-this.main_object:realPosition().y))
      end
    end
  )
  self:thereIsNoObjectBelow(
    function(this)
      local meter_s= 1
      this.force_acc.y= this.force_acc.y + (meter_s*0.1)
    end
  )
  if self.fixed~=true then self:applicationOfForce() end
end

function Physics:inside_the_area_of_y(object, previous_position)
  local distanceInYIgnoredAtTop=(self.force_acc.y>=0 and self.force_acc.y or 1)
  local distanceInYIgnoredAtBottom=(self.force_acc.y<=0 and self.force_acc.y or -1)
  return (
    self.main_object:getSide('bottom', previous_position)>object:getSide('top')+distanceInYIgnoredAtTop and
    self.main_object:getSide('top', previous_position)<object:getSide('bottom')+distanceInYIgnoredAtBottom
  )
end
function Physics:inside_the_area_of_x(object)
  return (
    self.main_object:getSide('right')>object:getSide('left') and
    self.main_object:getSide('left')<object:getSide('right')
  )
end

function Physics:collisions()
  if self.fixed~=true then
    for _, object in pairs(self.objects) do
      if self~=object then
        self:collision(object)
      end
    end
  end
end

-- tipo de colisão 1
function Physics:collision(object)
  if self:inside_the_area_of_y(object) and self.main_object.trajectory.modified_position.x==false then
    if (
      self.main_object:getSide('right')<=object:getSide('left')+16 and
      self.main_object:getSide('right', {x= self.main_object.trajectory:getCurrentMovement('x')+self.main_object.p.x})>=object:getSide('left')
    ) then
      self.main_object:setPosition('x', (object:getSide('left')-(self.main_object.body.w/2))-1)
      self.main_object.trajectory:setModifiedPosition('x')
    elseif (
      self.main_object:getSide('left')>=object:getSide('right')-16 and
      self.main_object:getSide('left', {x= self.main_object.trajectory:getCurrentMovement('x')+self.main_object.p.x})<=object:getSide('right')
    ) then
      self.main_object:setPosition('x', (object:getSide('right')+(self.main_object.body.w/2)+1))
      self.main_object.trajectory:setModifiedPosition('x')
    end
  end

  if self:inside_the_area_of_x(object) then
    if (
      self.main_object:getSide('bottom')>object:getSide('top') and
      self.main_object:getSide('bottom')<object:getSide('top')+(self.force_acc.y*2)
    ) then
      self.force_acc.y= mathK:around((self.force_acc.y~=0 and self.force_acc.y*-1 or self.force_acc.y)*self.energy_preservation)
      self.main_object.p.y= object:getSide('top')-(self.main_object.body.h/2)
    elseif (
      self.main_object:getSide('top')<object:getSide('bottom') and
      self.main_object:getSide('top')>object:getSide('bottom')+(self.force_acc.y*2)
    ) then
      self.force_acc.y= 0
      self.main_object.p.y= object:getSide('bottom')+(self.main_object.body.h/2)
    end
  end
end

function Physics:thereIsNoObjectBelow(func)
  local effect= true
  local x_range, y_range
  for _, object in pairs(self.objects) do
    if self.main_object~=object then
      x_range= (self.main_object:getSide('right')>object:getSide('left') and self.main_object:getSide('left')<object:getSide('right'))
      if x_range then
        y_range= (self.main_object:getSide('bottom')>object:getSide('top') and self.main_object:getSide('top')<object:getSide('bottom'))
        if y_range then
          effect= false
          break
        end
      end
    end
  end
  if effect then
    func(self)
  end
end

function Physics:aboveAndWithinTheRangeX(func_objs) -- dentro do intervalo x em relação a outro objeto, onde este está abaixo 
  local x_range
  for _, object in pairs(self.objects) do
    x_range= self.main_object~=object and (self.main_object:getSide('right')>object:getSide('left') and self.main_object:getSide('left')<object:getSide('right'))
    if x_range then
      if self.main_object:getSide('bottom')<object:getSide('top') then
        func_objs(self, object)
        break
      end
    end
  end
end

function Physics:impact_force(object)
  return (object.physics.mass*0.5)*self.energy_preservation
end

function Physics:applicationOfForce()
  self.main_object:move('x', self.force_acc.x)
  self.main_object:move('y', self.force_acc.y)
  self:energyLoss()
end

function Physics:energyLoss()
  local next_force_acc_x= 0
  if self.force_acc.x>0 then
    next_force_acc_x= -(0.5)*self.energy_preservation
  elseif self.force_acc.x<0 then
    next_force_acc_x= (0.5)*self.energy_preservation
  else
    return
  end
  self.force_acc.x= self.force_acc.x+next_force_acc_x
end

return Physics