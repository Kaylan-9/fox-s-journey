local Character= require('models.character')
local FlyingCharacter, metatable= {}, {
  __index=Character,
  __call=function(self, option_props, running_speed, starting_position, messages, speech_interruption, goto_player)
    local obj= Character(option_props, running_speed, starting_position, messages, speech_interruption, goto_player)  
    setmetatable(obj, {__index= self})
    obj:whereToFly()
    return obj
  end
}

setmetatable(FlyingCharacter, metatable)

function FlyingCharacter:whereToFly()

  if _G.player then  
    local player_y= _G.player.p.y
    local player_y_raio= (_G.player.body.h/2)
    if self.p.y<player_y-player_y_raio then
      local floor= self.new_y
      if self.p.y<floor then
        self.flight_direction= 'down'
      else 
        self.flight_direction= false
      end
    elseif self.p.y>player_y+player_y_raio then
      self.flight_direction= 'up'
    else
      local floor= self.new_y
      if self.p.y>floor then
        self.flight_direction= 'up'
      else
        self.flight_direction= false
      end
    end
  end
end

function FlyingCharacter:fly()
  self:whereToFly()
  if self.flight_direction=='down' then
    self.p.y= self.p.y + self.mov
  elseif self.flight_direction=='up' then
    self.p.y= self.p.y - self.mov
  end
end

return FlyingCharacter