local Trajectory= {}
local metatable= {
  __call= function(self, new_trajectory, main_object)
    local trajectory= {}
    trajectory.walking_speed= new_trajectory.walking_speed
    trajectory.current_walking_speed= new_trajectory.walking_speed.min
    trajectory.previous_positions= {}
    trajectory.max_n_positions= 49
    trajectory.main_object= main_object
    setmetatable(trajectory, {__index= self})
    trajectory:resetModifiedPosition()
    trajectory:resetCurrentMovement()
    trajectory:resetNextPosition()
    return trajectory
  end
}

setmetatable(Trajectory, metatable)

function Trajectory:getNextPosition(prop) return (prop and self.next_position[prop] or self.next_position) end
function Trajectory:setNextPosition(prop)
  if self.main_object.name=='player' then
    self.next_position[prop]= self.main_object.p[prop]-self.main_object.cam[prop]+self.current_movement[prop]
  end
end
function Trajectory:resetNextPosition() self.next_position= { x= 0, y= 0 } end

function Trajectory:getModifiedPosition(prop) return (prop and self.modified_position[prop] or self.modified_position) end
function Trajectory:setModifiedPosition(prop) self.modified_position[prop]= true end
function Trajectory:resetModifiedPosition() self.modified_position= { x= false, y= false } end

function Trajectory:getCurrentMovement(prop) return (prop and self.current_movement[prop] or self.current_movement) end
function Trajectory:setCurrentMovement(prop, new_value) self.current_movement[prop]= new_value end
function Trajectory:resetCurrentMovement() self.current_movement= { x= 0, y= 0 } end

function Trajectory:update(current_position)
  local current_movement_x= self:getCurrentMovement('x')
  local current_movement_y= self:getCurrentMovement('y')
  if current_movement_x~=0 or current_movement_y~=0 then self:addPreviousPosition(current_position) end
  self:setNextPosition('x')
  self:setNextPosition('y')
end

function Trajectory:draw()
  if #self.previous_positions>=self.max_n_positions then
    local mix_tbl_positions= {}
    for i=1, #self.previous_positions do
      table.insert(mix_tbl_positions, self.previous_positions[i].x)
      table.insert(mix_tbl_positions, self.previous_positions[i].y)
    end 
    love.graphics.line(unpack(mix_tbl_positions))
  end
end

function Trajectory:addPreviousPosition(current_position)
  if #self.previous_positions<self.max_n_positions then
    table.insert(self.previous_positions, _G.tbl:deepCopy(current_position))
  else
    table.remove(self.previous_positions, 1)
    table.insert(self.previous_positions, _G.tbl:deepCopy(current_position))
  end
end

function Trajectory:getLastPosition()
  if #self.previous_positions>1 then
    local last_index= #self.previous_positions-1
    return self.previous_positions[last_index]
  end 
  return false
end

return Trajectory
