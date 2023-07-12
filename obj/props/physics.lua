local Collision= require('obj.props.collision')
local Physics= {}
local metatable= {
  __call=function(self, new_physics, parent)
    local physics= {}
    physics.fixed= new_physics.fixed
    physics.objs= new_physics.objs
    physics.mass= new_physics.mass
    physics.drop_force_application_timer= timer:new({
      duration= 0.007,
      can_repeat=true,
      parent= self
    })
    physics.energy_preservation= new_physics.energy_preservation
    physics.force_acc= {
      y= 0,
      x= 0
    }
    physics.parent= parent
    physics.collision= Collision({
      objs= physics.objs
    }, parent)

    -- para mobs e inimigos do jogo
    if physics.parent.name~='player' and physics.parent.does_not_go_through_bottomless_holes then
      physics.future_force_acc= {
        y= 0,
        x= 0
      }
    end
    setmetatable(physics, {__index= self})
    return physics
  end
}
setmetatable(Physics, metatable)


-- executa interação entre objetos de interação
function Physics:execObjs(func, args, _break)
  for _, obj in pairs(self.objs) do
    if self.id~=obj.id then
      if func(self, obj, unpack(args)) or _break then
        -- 
        break
      end
    end
  end
end

function Physics:update()
  if self.parent.is_not_flying then
    -- para mobs e inimigos do jogo
    if self.parent.name~='player' and self.parent.does_not_go_through_bottomless_holes then
      self:objsWillNotBeBellow(function()
        self.parent.trajectory:setModifiedPosition('x')
      end)
    end
    self:aboveObjs(function(obj)
      if obj.physics then
        local meter_s= 2
        self.force_acc.y= self.force_acc.y + math.sqrt(
          (meter_s*obj.physics.mass)/(obj:realPosition('y')-self.parent:realPosition('y'))
        )
      end
    end)
    
    self:objsAreNotBelow(function()
      local meter_s= 10
      self.force_acc.y= self.force_acc.y + (meter_s*0.1)
    end)
    if self.force_acc.y~=0 then
      self.parent.trajectory:setCurrentMovement('y', self.force_acc.y)
    end
  end

  self.collision:update()
  if not self.parent.trajectory.modified_position.x then self.parent:move('x', self.parent.trajectory:getCurrentMovement('x')) end

  self.parent.trajectory:resetModifiedPosition()
  self.parent.trajectory:resetCurrentMovement()
  self.parent.trajectory:resetNextPosition()
  if not self.fixed then self:applicationOfForce() end
end

function Physics:inside_the_area_of(axle, obj)
  local inside_the_area= false
  if axle=='y' then
    inside_the_area= (
      self.parent:getSide('bottom')>obj:getSide('top')+1 and
      self.parent:getSide('top')<obj:getSide('bottom')-1
    )
  elseif axle=='x' then
    inside_the_area= (
      self.parent:getSide('right')>obj:getSide('left') and
      self.parent:getSide('left')<obj:getSide('right')
    )
  end 
  return inside_the_area
end

function Physics:objWillNotBellow(obj, obj_func)
  local calc_future_position_side= function(name_side)
    local current_movement_x= self.parent.trajectory:getCurrentMovement('x')
    local signal= current_movement_x>0 and 1 or -1
    local distance_to_calculate_the_floor= signal*((self.parent.body.w))
    if signal>0 then
      distance_to_calculate_the_floor= distance_to_calculate_the_floor>current_movement_x and distance_to_calculate_the_floor or current_movement_x
    elseif signal<0 then
      distance_to_calculate_the_floor= distance_to_calculate_the_floor<current_movement_x and distance_to_calculate_the_floor or current_movement_x
    end
    return self.parent:getSide(name_side, {x= self.parent:getSide(name_side)+(distance_to_calculate_the_floor)})
  end
  local x_range= (calc_future_position_side('right')>obj:getSide('left') and calc_future_position_side('left')<obj:getSide('right'))
  if x_range then
    local y_range= (self.parent:getSide('bottom')>obj:getSide('top') and self.parent:getSide('top')<obj:getSide('bottom'))
    if y_range then
      obj_func()
    end
  end
end

function Physics:objsWillNotBeBellow(func)
  local effect= true
  self:execObjs(self.objWillNotBellow, {function()
    effect= false
  end}, not effect)
  if effect then
    func()
  end
end

function Physics:objsAreNotBelow(func)
  local effect= true
  self:execObjs(self.objIsNotBelow, {function()
    effect= false
  end}, not effect)
  if effect then
    func()
  end
end

function Physics:aboveObjs(obj_func) -- dentro do intervalo x em relação a outro objeto, onde este está abaixo 
  if self.force_acc.y~=0 then
    self:execObjs(self.aboveObj, {obj_func}, false)
  end
end


function Physics:objIsNotBelow(obj, obj_func)
  local x_range= self:inside_the_area_of('x', obj)
  if x_range then
    local y_range= (self.parent:getSide('bottom')>obj:getSide('top') and self.parent:getSide('top')<obj:getSide('bottom'))
    if y_range then
      obj_func()
    end
  end
end


function Physics:aboveObj(obj, obj_func)
  local _break= false
  local x_range= self:inside_the_area_of('x', obj)
  if x_range then
    if self.parent:getSide('bottom')<obj:getSide('top')-1 then
      obj_func(self, obj)
      _break= true
    end
  end
  return _break
end

function Physics:applicationOfForce()
  self.drop_force_application_timer:finish()
  if self.parent.trajectory.modified_position.x==false then self.parent:move('x', self.force_acc.x) end
  if self.parent.trajectory.modified_position.y==false then self.parent:move('y', self.force_acc.y) end
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