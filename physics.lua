local Physics= {}
local metatable= {
  __call=function(self, customizable)
    local physics= {}
    physics.fixed= customizable.fixed
    physics.main_object= customizable.main_object
    physics.objects= customizable.objects
    physics.mass= customizable.mass
    physics.energy_preservation= customizable.energy_preservation
    physics.force_acc= {}
    physics.force_acc.y= 0
    physics.force_acc.x= 0
    setmetatable(physics, {__index= self})
    return physics
  end
}
setmetatable(Physics, metatable)

function Physics:update()
  self:collisions()
  if self.fixed~=true then self:applicationOfForce() end
end

function Physics:inside_the_area_of_y(object, previous_position)
  local distanceInYIgnoredAtTop=(self.force_acc.y>=0 and self.force_acc.y or 1)
  local distanceInYIgnoredAtBottom=(self.force_acc.y>=0 and self.force_acc.y or -1)
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
        self:fastCollisionWithElements(object)
        self:collision(object)
      end
    end
  end
  self:aboveAndWithinTheRangeX(function() self.force_acc.y= self.force_acc.y+(0.1) end)
end

function Physics:fastCollisionWithElements(object)
  local last_position= self.main_object.trajectory:getLastPosition()
  if last_position then
    if self:inside_the_area_of_y(object) and self:inside_the_area_of_y(object, last_position) then
      if self.main_object:getSide('right')<object:getSide('right') and self.main_object:getSide('right', last_position)>object:getSide('left') then
        self.main_object.p.x= object:getSide('right')+(self.main_object.body.w/2)
      end
      if self.main_object:getSide('left')>object:getSide('left') and self.main_object:getSide('left', last_position)<object:getSide('right') then
        self.main_object.p.x= object:getSide('left')-(self.main_object.body.w/2)
      end
    end
  end
end

-- tipo de colisão 1
function Physics:collision(object)
  if self:inside_the_area_of_y(object) then
    if (
      self.main_object:getSide('right')>object:getSide('left')-self.main_object.trajectory.current_walking_speed and
      self.main_object:getSide('right')<object.p.x
    ) then 
      self.main_object.p.x= object:getSide('left')-(self.main_object.body.w/2)
      -- self.force_acc.x= self.force_acc.x-self:impact_force(object)
    elseif (
      self.main_object:getSide('left')<object:getSide('right')+self.main_object.trajectory.current_walking_speed and
      self.main_object:getSide('left')>object.p.x
    ) then
      self.main_object.p.x= object:getSide('right')+(self.main_object.body.w/2)
      -- self.force_acc.x= self.force_acc.x+self:impact_force(object)
    end
  end

  if self:inside_the_area_of_x(object) then
    if (
      self.main_object:getSide('bottom')>object:getSide('top') and
      self.main_object:getSide('bottom')<object:getSide('top')+(self.force_acc.y*5)
    ) then
      self.force_acc.y= mathK:around((self.force_acc.y*-1)*self.energy_preservation)
      self.main_object.p.y= object:getSide('top')-(self.main_object.body.h/2)
      -- self.force_acc.y= self.force_acc.y-(0.05)
    elseif (
      self.main_object:getSide('top')<object:getSide('bottom') and
      self.main_object:getSide('top')>object:getSide('bottom')+(self.force_acc.y*5)
    ) then
      self.force_acc.y= 0
      self.main_object.p.y= object:getSide('bottom')+(self.main_object.body.h/2)
      -- self.force_acc.y= self.force_acc.y+(0.1)
    end
  end
end

function Physics:aboveAndWithinTheRangeX(func) -- dentro do intervalo x em relação a outro objeto, onde este está abaixo 
  for _, object in pairs(self.objects) do
    if self~=object then
      if self:inside_the_area_of_x(object) then
        if self.main_object:getSide('bottom')<object:getSide('top') then
          func(self)
        end
      end
    end
  end
end

function Physics:impact_force(object)
  return (object.physics.mass*0.5)*self.energy_preservation
end

function Physics:applicationOfForce()
  self.main_object.p.x= self.main_object.p.x+self.force_acc.x
  self.main_object.p.y= self.main_object.p.y+self.force_acc.y
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