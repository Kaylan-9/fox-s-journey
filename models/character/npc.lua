local Character= require('models.character.character')
local NPC, metatable= {}, {
  __index= Character,
  __call= function(self, option_props, running_speed, starting_position, messages, speech_interruption, goto_player)
    local obj= Character(option_props, running_speed, starting_position, false, option_props.name, messages, speech_interruption)
    obj.goto_player= goto_player
    setmetatable(obj, {__index= self})
    obj:setPropsForFlyingCharacter()
    return obj
  end
}

setmetatable(NPC, metatable)

-- definir propriedades do NPC se é do tipo voador
function NPC:setPropsForFlyingCharacter()
  if self.type=='flying' then
    self.recently_attacked= timer:new(5)-- serve para definir um timer para contabilizar um certo tempo após o ataque do player
    self.center_radius= 0 --  serve para definir até que coordenada NPC deve subir para fugir do player ao receber dano do mesmo
  end 
end

function NPC:playerVisible()
  local res= self.field_of_view==true or ((type(self.field_of_view)~='boolean' and _G.cam and math.abs(_G.cam:actualPlayerPosition()-self.p.x)<=self.field_of_view))
  if res then 
    self:fly() 
    self:bossChasesPlayerAcrossMap() -- ao encontrar com o player o boss persegue o player independente de onde ele esteja na fase
  end
  return res
end

function NPC:bossChasesPlayerAcrossMap()
  if self.its_the_boss then self.field_of_view= true end 
end


-- #executado para verificar se o NPC tem a respectiva animação com base no frame_positions, caso não tenha ele pula a função ou executa sem esperar animação
function NPC:temAnim(name_anim)
  local res= self.frame_positions[name_anim]
  if res then self.animation=name_anim end
  return res
end


-- muda o sentido do personagem para a direita
function NPC:shiftRight()
  self.s.x= -math.abs(self.s.x)*self.direction
end

-- muda o sentido do personagem para a esquerda
function NPC:shiftLeft()
  self.s.x= math.abs(self.s.x)*self.direction
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


      if self.flight_direction=='curved-climb' then
        self:shiftLeft()
        self.p.x= (self.p.x + self.mov)
      else
        self:shiftRight()
        self.p.x= (self.p.x - self.mov)
      end

      self.reached_the_player= false
    elseif (right<playersLeftSide) and self.goto_player then
      self.animation= self.type=='flying' and 'flying' or 'walking'
      self:defaultUpdateFrame()

      if self.flight_direction=='curved-climb' then
        self:shiftRight()
        self.p.x= (self.p.x - self.mov)
      else
        self:shiftLeft()
        self.p.x= (self.p.x + self.mov)
      end

      self.reached_the_player= false
    else 
      self.reached_the_player= true

      if self.flight_direction=='curved-climb' then
        self.p.x= (self.p.x+((self.s.x>0 and 1 or -1)*self.mov))
      end 
    end
  end
end

function NPC:verSeExisteDialogoQueIterrompe()
  if self.speech_interruption then
    _G.balloon.messages= self.messages
    self.speech_interruption= false
    return true 
  end
  return false
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

  if not _G.player.was_destroyed then  
    local player_y= _G.player.p.y
    local player_y_raio= (_G.player.body.h/2)

    if self.recently_attacked:finish() then
      self.recently_attacked:reset()
      if self.p.y<player_y-player_y_raio then naoPodeAtrevessarChaoQuanPlayerAbaixo()
      elseif self.p.y>player_y+player_y_raio then self.flight_direction= 'up'
      else seEstaAbaixoDoChaoNoIntervaloPlayer()
      end
    else 
      self.flight_direction= 'curved-climb'
    end

  end
end

-- serve para calcular o próximo movimento do personagem voador e sua intensidade
function NPC:curvedClimb()
  return math.cos((self.p.x-(self.center_radius))/75)*self.mov*(math.random(1, 4))
end

-- direciona NPC voador se é voador
function NPC:fly()
  if self.type=='flying' then 
    self:whereToFly()
    if self.flight_direction=='down' then
      self.p.y= self.p.y + self.mov
    elseif self.flight_direction=='up' then
      self.p.y= self.p.y - self.mov
    elseif self.flight_direction=='curved-climb' then
      self.p.y= self.p.y - self:curvedClimb()
    end

  end
end

function NPC:iniciarDialogo(key, scancode, isrepeat)
  if key=='f' then 
    local pode_iniciar_dialogo= (#_G.balloon.messages==0)

    if self.reached_the_player then
      if pode_iniciar_dialogo then 
        _G.balloon.messages= self.messages
      else
        if _G.balloon.indice>=#_G.balloon.messages then 
          _G.balloon.indice= 1
          _G.balloon.messages= {}
        else
          _G.balloon.indice= _G.balloon.indice + 1
        end
      end
    end 
    
  end
end

return NPC