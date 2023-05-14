local Tileset= require('models.tileset')
local Character= require('models.character')
local player= Character(
{
  name= "Faye",
  s= {x= 2.5, y= 2.5},
  imgname= "midi.png",
  frame_positions= {},
  hostile= {
    damage= 1,
    attack_frame= 88
  },
  frame_n= {x=16, y=15},
  adjustment= nil,
  body= {w=30, h=30}
},
4,
{x= 30, y= 0})
player.canjump= true
player.expression= {
  s= {x= 1.5, y= 1.5},
  frame= 1,
  tileset= Tileset('assets/graphics/sprMidiF.png', {x=4, y=3}, {w=-0.34, h=0.5})
}
player.pressed= {}  

function player:updateFrame(nao_ha_messages)
  self.pressed.mov= love.keyboard.isDown("right", "d", "left", "a")
  self.pressed.run= self.pressed.mov and love.keyboard.isDown("space")
  self.pressed.jump= love.keyboard.isDown("up", "w")
  self.pressed.soco= love.keyboard.isDown("x")

  local sendo_controlado= self.pressed.mov or self.pressed.run or self.pressed.jump or self.pressed.soco

  if (sendo_controlado and nao_ha_messages==true) or (self.canjump==false) or (self.pressed.jump==false and self.p.y<self.p.f.y) then
    self.acc= self.acc+(_G.dt * math.random(1, 3))
    if self.acc>=self.freq_frames then
      self.frame= self.frame + 1
      self.acc= 0
    end
  else
    self.frame= 1
  end
end

function player:queda()
  if (self.canjump==false) or (love.keyboard.isDown("up", "w")==false and self.p.y<self.p.f.y) then 
    local d_between_iy_fy= (self.p.f.y-self.p.i.y)
    local d_between_iy_y= (self.p.y-self.p.i.y)
    self.p.y= self.p.y + (_G.dt * (math.ceil(1-(((d_between_iy_fy)-(d_between_iy_y))/(d_between_iy_fy)))+0.1) * 100)
    self:exe_ciclo_anim_pulo()
  end
end

function player:exe_ciclo_anim_queda()
  if self.canjump==false then
    if (self.frame==(11+5+1)) then --troca para outra sequência de frames
      self.frame= 13
    elseif (self.frame<11 or self.frame>(11+5)) then 
      self.frame= 11
    end
  end
end

function player:exe_ciclo_anim_pulo()
  if self.pressed.jump and self.canjump then
    if (self.frame<8 or self.frame>(8+2)) then self.frame=8 end
  end
end

function player:pulo()
  if love.keyboard.isDown("up", "w") and self.canjump==true then
    self:exe_ciclo_anim_pulo()    
    local d_between_iy_fy= (self.p.f.y-self.p.i.y)
    local d_between_iy_y= (self.p.y-self.p.i.y)
    self.p.y= self.p.y - (_G.dt * math.ceil(1-(((d_between_iy_fy)-(d_between_iy_y))/(d_between_iy_fy))) * 0.75 * 100)
  end
end

function player:exe_ciclo_anim_mov()
  -- se não está pressionado o botão de pulo & o player pode pular
  if self.pressed.jump==false and self.canjump then
    if ((self.frame<17 or self.frame>(17+7)) and not love.keyboard.isDown("space")) then    self.frame= 17
    elseif ((self.frame<33 or self.frame>(33+7)) and love.keyboard.isDown("space")) then self.frame= 33
    end
  end
end

function player:mudanca_direcao()
  if love.keyboard.isDown("left", "a") then self.s.x= -math.abs(self.s.x)
  elseif love.keyboard.isDown("right", "d") then self.s.x= math.abs(self.s.x)
  end
end 

function player:moveX(mov)
  local posicao_cam_inativa_e_igual= (_G.map.cam.p.x+self.p.x<=_G.map.cam.p.i.x+(self.vel*2)) or (_G.map.cam.p.x+self.p.x>=_G.map.cam.p.f.x-self.vel)
  --limite na tela com base no controle do player
  local lim= {
    left= (self.p.x>(self.vel*2)) and posicao_cam_inativa_e_igual,
    right= (self.p.x<(_G.screen.w-(self.vel*2))) and posicao_cam_inativa_e_igual
  }

  if self.pressed.mov then self:exe_ciclo_anim_mov() end
  if love.keyboard.isDown("left", "a") and lim.left then self.p.x= self.p.x-mov
  elseif love.keyboard.isDown("right", "d") and lim.right then self.p.x= self.p.x+mov
  end
end

function player:soco()
  if not self.pressed.jump and not self.pressed.mov and not self.pressed.run then
    if self.pressed.soco then 
      if self.frame<88 or self.frame>(88+8) then
        self.frame= 88
      end 
    end
  end
end

function player:update()
  local nao_ha_messages= (#_G.balloon.messages==0)
  self:updateParameters(true)
  self:calcYPositionReferences()
  self:updateFrame(nao_ha_messages)
  self:queda()
  if nao_ha_messages then
    self:soco()
    self:mudanca_direcao()
    self:moveX((_G.dt * self.vel * 100))
    self:pulo()
    self.vel= love.keyboard.isDown("space") and self.max_vel or self.vel
  end
end

function player:calcYPositionReferences()
  -- incia a posição máxima de y
  -- incia posição de y do player na tela
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


function player:drawExpression()
  love.graphics.draw(self.expression.tileset.obj, self.expression.tileset.tiles[self.expression.frame], 0, _G.screen.h-(self.expression.tileset.tileSize.h*1.5), 0, self.expression.s.x, self.expression.s.y)
end

return player