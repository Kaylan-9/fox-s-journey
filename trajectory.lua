local Trajectory= {}
local metatable= {
  __call= function(self, new_trajectory)
    local trajectory= {}
    trajectory.next_move= 0
    trajectory.p= new_trajectory.p
    trajectory.walking_speed= new_trajectory.walking_speed
    trajectory.current_walking_speed= new_trajectory.walking_speed.min
    trajectory.previous_positions= {}
    trajectory.max_n_positions= 10
    setmetatable(trajectory, {__index= self})
    return trajectory
  end
}

setmetatable(Trajectory, metatable)

function Trajectory:update(current_position)
  if self.next_move~=0 then
    self:addPreviousPosition(current_position)
    self:setNextMove(0)
  end
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

function Trajectory:setNextMove(next_move) self.next_move= next_move end
function Trajectory:getNextMove() return self.next_move end
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
