local Tileset= require('models.tileset')
local Character= require('models.character.character')
local Player= {}
local metatable= {
  __index= Character,
  __call=function(self)
    local obj= Character(
      {
        name= "Faye", 
        s= {x= 2.5, y= 2.5}, 
        frame_positions= {
          walking= {i= 17, f= 24, type= "default"},
          attacking= {i= 89, f= 96, type= "until_finished", audio='player_hit.mp3'},
          running= {i= 33, f= 40, type= "default"},
          jumping= {i= 9, f= 10, type= "default", audio='player_jump.wav'},
          falling= {i= 12, f= 16, type= "default"},
          finishing= {i= 237, f= 238, type= "default"}
        }, 
        hostile= {damage= 1, attack_frame= {90, 94}}, 
        body= {w=30, h=80}
      },
      4,
      {x= 30, y= 0},
      true,
      "player"
    ) 
    obj.pressed= {}
    obj.canjump= true
    setmetatable(obj, {__index= self})
    return obj
  end
}

setmetatable(Player, metatable)

-- Cria propriedades dentro de pressed para indicar se as teclas respectivas das determinadas ações são executadas, não necessariamente ao pressionar a ação ele deve ser executada, por exemplo: ao pressionar o soco ele deve socar só se as condições para o soco forem positivas
function Player:markPressedKeys()
  self.pressed.soco= love.keyboard.isDown("x") 
  self.pressed.mov_left= love.keyboard.isDown("left", "a")
  self.pressed.mov_right= love.keyboard.isDown("right", "d")
  self.pressed.mov= self.pressed.mov_left or self.pressed.mov_right
  self.pressed.run= self.pressed.mov and love.keyboard.isDown("space")
  self.pressed.jump= love.keyboard.isDown("up", "w")
end

function Player:sendoControlado()
  local controlando= false
  for k, _ in pairs(self.pressed) do
    if self.pressed[k] then
      controlando= true
      break
    end     
  end
  return controlando
end

function Player:updateFrame()
  local esperando_soco= (self.animation=='attacking' and self.frame>=self.frame_positions.attacking.i and self.frame<=self.frame_positions.attacking.f-1)
  local mudanca_frame= (self:sendoControlado() and #_G.balloon.messages==0) or (self.pressed.jump==false and self.p.y<self.p.f.y) or (#_G.balloon.messages==0 and esperando_soco)
  
  self:defaultUpdateFrame(mudanca_frame)
end

function Player:queda()
  if (self.canjump==false) or (love.keyboard.isDown("up", "w")==false and self.p.y<self.p.f.y) then 
    local d_between_iy_fy= (self.p.f.y-self.p.i.y)
    local d_between_iy_y= (self.p.y-self.p.i.y)
    self.p.y= self.p.y + (_G.dt * (math.ceil(1-(((d_between_iy_fy)-(d_between_iy_y))/(d_between_iy_fy)))+0.1) * 500)
    self:exeCicloAnimQueda()
  end
end

function Player:exeCicloAnimQueda()
  if self:animComecaExec() then
    if self.canjump==false then
      self.animation= 'falling'
    end
  end
end

function Player:exeCicloAnimPulo()
  if self:animComecaExec() then
    if self.pressed.jump and self.canjump then
      self.animation= 'jumping'
    end
  end
end

function Player:keypressed(key, scancode, isrepeat)
  self:exeAudioPuloKeypressed(key, isrepeat)
end

function Player:exeAudioPulo()
  -- reseta o tempo se o canjump é true
  if self.p.y>=self.y_from_the_current_floor then self.timer_sem_tocar_audio_ha:reset() end 
  -- nennhum audio do player foi tocado e o audio não está tocando
  if not self.audios.jumping:isPlaying() then
    if self.timer_sem_tocar_audio_ha:finish() then
      self.audios.jumping:play()  
      self.timer_sem_tocar_audio_ha:reset()
    end 
  else self.timer_sem_tocar_audio_ha:start()
  end
end

function Player:exeAudioPuloKeypressed(key, isrepeat)
  if (key=='up' or key=='w') and self.canjump and not isrepeat then
    self.audios.jumping:play()
  end
end

function Player:pulo()
  if love.keyboard.isDown("up", "w") and self.canjump==true then
    self:exeCicloAnimPulo()    
    self:exeAudioPulo()
    local d_between_iy_fy= (self.p.f.y-self.p.i.y)
    local d_between_iy_y= (self.p.y-self.p.i.y)
    self.p.y= self.p.y - (_G.dt * math.ceil(1-(((d_between_iy_fy)-(d_between_iy_y))/(d_between_iy_fy))) * 0.95 * 500)
  end
end

function Player:parametersToAllowMoveWhenTyingToWalk(param)
  local posicao_cam_inativa_e_igual= (_G.cam.p.x+self.p.x<=_G.cam.p.i.x+(self.vel*2)) or (_G.cam.p.x+self.p.x>=_G.cam.p.f.x-self.vel)
  --limite na tela com base no controle do Player
  local lim= {
    left= (self.p.x>(self.vel*2)) and posicao_cam_inativa_e_igual,
    right= (self.p.x<(_G.screen.w-(self.vel*2))) and posicao_cam_inativa_e_igual
  }

  local ver_padrao= {
    left= (love.keyboard.isDown("left", "a") and self.p.x>(self.vel*2)),
    right= (love.keyboard.isDown("right", "d") and (self.p.x<(_G.screen.w-(self.vel*2))))
  }

  return (ver_padrao[param] and lim[param])
end

function Player:corrida()
  self.vel= love.keyboard.isDown("space") and self.max_vel or self.vel
end 

-- método para verificar se personagem deve ou não se mover, ele é utilizado em um "if"
function Player:permitirMove()
  return #_G.balloon.messages==0 and self.animation~='finishing'
end

function Player:mudancaDirecao()
  if love.keyboard.isDown("left", "a") then self.s.x= -math.abs(self.s.x)
  elseif love.keyboard.isDown("right", "d") then self.s.x= math.abs(self.s.x)
  end
end 

function Player:soco()
  if self:animComecaExec() then
    if self.pressed.soco then 
      self.animation= 'attacking'
    end
  end
end

function Player:exeCicloAnimMov()
  -- se não está pressionado o botão de pulo & o Player pode pular
  if self:animComecaExec() then
    if self.pressed.jump==false and self.canjump and self.pressed.mov then

      if self.pressed.run then
        self.animation= 'running'
      elseif self.pressed.mov then
        self.animation= 'walking'
      end

    end
  end
end

function Player:andar()
  self.mov= math.ceil(_G.dt * self.vel * 100)
  if self.pressed.mov then self:exeCicloAnimMov() end
  if self:parametersToAllowMoveWhenTyingToWalk('left') then self.p.x= self.p.x-self.mov end
  if self:parametersToAllowMoveWhenTyingToWalk('right') then self.p.x= self.p.x+self.mov end
end

-- serve para verificar se a animação começa 
function Player:animComecaExec()         
  return self.animation=='' or self.frame_positions[self.animation].type~='until_finished' or self.frame_positions[self.animation].f==self.frame      
end

function Player:controlando()
  self:markPressedKeys()
  if self:permitirMove() then
    self:soco()
    self:mudancaDirecao()
    self:andar()
    self:pulo()
    self:corrida()
  end
end

function Player:update()
  self:updateProperties()
  self:calcYPositionReferences()
  self:updateFrame()
  self:queda()
  self:controlando()
  self:finalizando()
  self.frame_acc= self.frame_acc+(_G.dt * math.random(1, 3))
  self:dying()
end


function Player:dying()
  if self.life<=0 then
    self:destroy()
  end
end 

function Player:calcYPositionReferences()
  -- incia a posição máxima de y
  -- incia posição de y do Player na tela
  if self.p.f.y==-100 then self.p.i.y, self.p.y, self.p.f.y= self.y_from_the_current_floor-90, self.y_from_the_current_floor, self.y_from_the_current_floor end

  --controla, mudando a sua propriedade de permissão do pulo e corrige o valor de y para o máximo || mínimo
  if self.p.y>=self.p.f.y then 
    self.p.y= self.p.f.y
    self.canjump= true
  elseif self.p.y<=self.p.i.y then self.canjump= false end

  -- compara se o personagem está próximo da elevação mais próxima
  if (self.p.y==self.p.f.y) or (self.p.y>=self.y_from_the_current_floor) then self.p.f.y= self.y_from_the_current_floor end
  if  (self.p.y==self.p.f.y) then self.p.i.y= self.y_from_the_current_floor-90 end
end

function Player:finalizando()
  if (_G.boss.was_destroyed==true and #_G.npcs.on_the_screen==0) then
    self.animation= 'finishing'
  end
end

function Player:frameAoTerminarFase()
  return self.frame==self.frame_positions.finishing.f
end

return Player