local Character= require('models.character.character')
local NPC, metatable= {}, {
  __index= Character,
  __call= function(self, option_props, running_speed, starting_position, messages, speech_interruption, goto_player)
    local obj= Character(option_props, running_speed, starting_position, false, option_props.name, messages, speech_interruption)
    obj.goto_player= goto_player
    setmetatable(obj, {__index= self})
    return obj
  end
}

setmetatable(NPC, metatable)

function NPC:playerVisible()
  local metade_tela= (_G.screen.w/2)
  local res= _G.cam and math.abs(_G.cam:actualPlayerPosition()-self.p.x)<=metade_tela
  if res then self:fly() end
  return res
end

-- #executado para verificar se o NPC tem a respectiva animação com base no frame_positions, caso não tenha ele pula a função ou executa sem esperar animação
function NPC:temAnim(name_anim)
  local res= self.frame_positions[name_anim]
  if res then self.animation=name_anim end
  return res
end

function NPC:chasePlayer()
  if not _G.player.was_destroyed then 
    local left= (self.p.x-(self.body.w/2)-1)-_G.cam.p.x
    local right= (self.p.x+(self.body.w/2)+1)-_G.cam.p.x

    local playersLeftSide= _G.player.p.x-(_G.player.body.w/2)
    local playersRightSide= _G.player.p.x+(_G.player.body.w/2)

    if (left>playersRightSide) and self.goto_player then
      self.animation= self.type=='flying' and 'flying' or 'walking'
      self:defaultUpdateFrame()
      self.s.x= -math.abs(self.s.x)*self.direction
      self.p.x= (self.p.x - self.mov)
      self.reached_the_player= false
    elseif (right<playersLeftSide) and self.goto_player then
      self.animation= self.type=='flying' and 'flying' or 'walking'
      self:defaultUpdateFrame()
      self.s.x= math.abs(self.s.x)*self.direction
      self.p.x= (self.p.x + self.mov)
      self.reached_the_player= false
    else 
      self.reached_the_player= true
    end
  end
end


function NPC:whereToFly()
  local naoPodeAtrevessarChaoQuanPlayerAbaixo= function()
    local floor= self.y_from_the_current_floor
    if self.p.y<floor then
      self.flight_direction= 'down'
    else 
      self.flight_direction= false
    end
  end
  local seEstaAbaixoDoChaoNoIntervaloPlayer= function()
    local floor= self.y_from_the_current_floor
    if self.p.y>floor then
      self.flight_direction= 'up'
    else
      self.flight_direction= false
    end
  end

  if _G.player then  
    local player_y= _G.player.p.y
    local player_y_raio= (_G.player.body.h/2)
    if self.p.y<player_y-player_y_raio then naoPodeAtrevessarChaoQuanPlayerAbaixo()
    elseif self.p.y>player_y+player_y_raio then self.flight_direction= 'up'
    else seEstaAbaixoDoChaoNoIntervaloPlayer()
    end
  end
end

-- direciona NPC voador se é voador
function NPC:fly()
  if self.type=='flying' then 
    self:whereToFly()
    if self.flight_direction=='down' then
      self.p.y= self.p.y + self.mov
    elseif self.flight_direction=='up' then
      self.p.y= self.p.y - self.mov
    end
  end
end

return NPC