local Tileset= require('models.tileset')
local Character= require('models.character')
local Player= {}
local metatable= {
  __index= Character,
  __call=function(self)
    local obj= Character(
      {
        name= "Faye", 
        s= {x= 2.5, y= 2.5}, 
        imgname= "midi.png", 
        frame_positions= {
          walking= {i= 17, f= 24, until_finished= false},
          attacking= {i= 89, f= 96, until_finished= true},
          running= {i= 33, f= 40, until_finished= false},
          jumping= {i= 9, f= 10, until_finished= false},
          falling= {i= 12, f= 16, until_finished= false}
        }, 
        hostile= {damage= 1, attack_frame= {90, 94}}, 
        frame_n= {x=16, y=15}, 
        adjustment= nil, 
        body= {w=30, h=80}
      },
      4,
      {x= 30, y= 0},
      true
    ) 
    obj.pressed= {}
    obj.canjump= true
    obj.expression= {}
    obj.expression.s= {x= 1.5, y= 1.5}
    obj.expression.frame= 1
    obj.expression.tileset= Tileset('assets/graphics/sprMidiF.png', {x=4, y=3}, {w=-0.34, h=0.5})
    setmetatable(obj, {__index= self})
    return obj
  end
}

setmetatable(Player, metatable)

function Player:updateFrame(nao_ha_messages)
  self.pressed.mov= love.keyboard.isDown("right", "d", "left", "a")
  self.pressed.run= self.pressed.mov and love.keyboard.isDown("space")
  self.pressed.jump= love.keyboard.isDown("up", "w")
  self.pressed.soco= love.keyboard.isDown("x") or (self.frame>=self.frame_positions.attacking.i and self.frame<=self.frame_positions.attacking.f-1)

  local sendo_controlado= self.pressed.mov or self.pressed.run or self.pressed.jump or self.pressed.soco
  local mudanca_frame= 
    self.pressed.soco or 
    (sendo_controlado and nao_ha_messages==true) or 
    (self.canjump==false) or 
    (self.pressed.jump==false and self.p.y<self.p.f.y)

  self:defaultUpdateFrame(mudanca_frame)
end

function Player:queda()
  if (self.canjump==false) or (love.keyboard.isDown("up", "w")==false and self.p.y<self.p.f.y) then 
    local d_between_iy_fy= (self.p.f.y-self.p.i.y)
    local d_between_iy_y= (self.p.y-self.p.i.y)
    self.p.y= self.p.y + (_G.dt * (math.ceil(1-(((d_between_iy_fy)-(d_between_iy_y))/(d_between_iy_fy)))+0.1) * 100)
    self:exeCicloAnimQueda()
  end
end

function Player:exeCicloAnimQueda()
  if self:animaContinuaEmExec() then
    if self.canjump==false then
      self.animation= 'falling'
      -- if (self.frame==(11+5+1)) then --troca para outra sequência de frames
      --   self.frame= 13
      -- elseif (self.frame<11 or self.frame>(11+5)) then 
      --   self.frame= 11
      -- end
    end
  end
end

function Player:exeCicloAnimPulo()
  if self:animaContinuaEmExec() then
    if self.pressed.jump and self.canjump then
      self.animation= 'jumping'
    end
  end
end

function Player:pulo()
  if love.keyboard.isDown("up", "w") and self.canjump==true then
    self:exeCicloAnimPulo()    
    local d_between_iy_fy= (self.p.f.y-self.p.i.y)
    local d_between_iy_y= (self.p.y-self.p.i.y)
    self.p.y= self.p.y - (_G.dt * math.ceil(1-(((d_between_iy_fy)-(d_between_iy_y))/(d_between_iy_fy))) * 0.75 * 100)
  end
end

function Player:animaContinuaEmExec()         
                               -- animação não é continua                                        -- É o frame final para terminar a animação     
  return self.animation=='' or not self.frame_positions[self.animation].until_finished or self.frame_positions[self.animation].f==self.frame
end

function Player:exeCicloAnimMov()
  -- se não está pressionado o botão de pulo & o Player pode pular
  if self:animaContinuaEmExec() then
    if self.pressed.jump==false and self.canjump and self.pressed.mov then
      self.animation= not love.keyboard.isDown("space") and 'walking' or 'running'
    end
  end
end

function Player:mudancaDirecao()
  if love.keyboard.isDown("left", "a") then self.s.x= -math.abs(self.s.x)
  elseif love.keyboard.isDown("right", "d") then self.s.x= math.abs(self.s.x)
  end
end 

function Player:moveX(mov)
  local posicao_cam_inativa_e_igual= (_G.map.cam.p.x+self.p.x<=_G.map.cam.p.i.x+(self.vel*2)) or (_G.map.cam.p.x+self.p.x>=_G.map.cam.p.f.x-self.vel)
  --limite na tela com base no controle do Player
  local lim= {
    left= (self.p.x>(self.vel*2)) and posicao_cam_inativa_e_igual,
    right= (self.p.x<(_G.screen.w-(self.vel*2))) and posicao_cam_inativa_e_igual
  }

  local ver_padrao= {
    left= (love.keyboard.isDown("left", "a") and not _G.npcs:naoPermiteSeMoverPara('left') and self.p.x>(self.vel*2)),
    right= (love.keyboard.isDown("right", "d") and not _G.npcs:naoPermiteSeMoverPara('right') and (self.p.x<(_G.screen.w-(self.vel*2))))
  }

  if self.pressed.mov then self:exeCicloAnimMov() end
  if (ver_padrao.left and lim.left) or (ver_padrao.left and _G.npcs.boss.active) then 
    self.p.x= self.p.x-mov
  elseif (ver_padrao.right and lim.right) or (ver_padrao.right and _G.npcs.boss.active) then 
    self.p.x= self.p.x+mov
  end
end

function Player:soco()
  -- if not self.pressed.jump and not self.pressed.mov and not self.pressed.run then
  if self:animaContinuaEmExec() then
    if self.pressed.soco then 
      self.animation= 'attacking'
    end
  end
  -- end
end

function Player:update()
  local nao_ha_messages= (#_G.balloon.messages==0)
  self:updateParameters(true)
  self:calcYPositionReferences()
  self:updateFrame(nao_ha_messages)
  self:queda()
  if nao_ha_messages then
    self:soco()
    self:mudancaDirecao()
    self:moveX((_G.dt * self.vel * 100))
    self:pulo()
    self.vel= love.keyboard.isDown("space") and self.max_vel or self.vel
  end
  self.acc= self.acc+(_G.dt * math.random(1, 3))
end

function Player:calcYPositionReferences()
  -- incia a posição máxima de y
  -- incia posição de y do Player na tela
  if self.p.f.y==-100 then self.p.i.y, self.p.y, self.p.f.y= self.new_y-90, self.new_y, self.new_y end

  --controla, mudando a sua propriedade de permissão do pulo e corrige o valor de y para o máximo || mínimo
  if self.p.y>=self.p.f.y then 
    self.p.y= self.p.f.y
    self.canjump= true
  elseif self.p.y<=self.p.i.y then self.canjump= false end

  -- compara se o personagem está próximo da elevação mais próxima
  if (self.p.y==self.p.f.y) or (self.p.y>=self.new_y) then self.p.f.y= self.new_y end
  if  (self.p.y==self.p.f.y) then self.p.i.y= self.new_y-90 end
end


function Player:drawExpression()
  love.graphics.draw(self.expression.tileset.obj, self.expression.tileset.tiles[self.expression.frame], 0, _G.screen.h-(self.expression.tileset.tileSize.h*1.5), 0, self.expression.s.x, self.expression.s.y)
  _G.collision:quadDraw(self)
end

return Player