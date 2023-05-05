local Tileset= require('components.tileset')
local Character= require('components.character')
local player= Character({
  name= "Faye",
  imgname= "midi.png",
  frame_n= {x=16, y=15},
  frame_positions= {},
  adjustment= {w=-0.34, h=0.5}
}, 1, {x= 30, y= 0})
player.jump= {reached= false}
player.ctrls= {'a', 's', 'w', 'd', 'left', 'down', 'up', 'right', 'space'}
player.pressed= false
player.expression= {
  s= {x= 1.5, y= 1.5},
  frame= 1,
  tileset= Tileset('assets/graphics/sprMidiF.png', {x=4, y=3}, {w=-0.34, h=0.5})
}

function player:keypressed(key) 
  if self.pressed~=true then
    for i=1, #self.ctrls, 1 do
      if key==self.ctrls[i] then
        self.pressed= true
        break
      end
    end
  end
end

function player:keyreleased() self.pressed= false end

function player:updateFrame(dt)
  local pressed= {}
  pressed.mov= love.keyboard.isDown("right", "d", "left", "a")
  pressed.run= pressed.mov and love.keyboard.isDown("space")
  pressed.jump= love.keyboard.isDown("up", "w")

  if pressed.mov or pressed.run or pressed.jump or (self.jump.reached==true) or (love.keyboard.isDown("up", "w")==false and self.p.y<self.p.f.y) then
    self.acc= self.acc+(dt * math.random(1, 3))
    if self.acc>=0.35 then
      self.frame= self.frame + 1
      self.acc= 0
    end
  else
    self.frame= 1
  end
end

function player:update(dt, cam)
  local mov= (dt * self.vel * 100)
  self:updateFrame(dt)

  if self.p.y>=self.p.f.y then self.jump.reached= false
  elseif self.p.y<=self.p.i.y then self.jump.reached= true
  end

  if (self.jump.reached==true) or (love.keyboard.isDown("up", "w")==false and self.p.y<self.p.f.y) then 
    local d_between_iy_fy= (self.p.f.y-self.p.i.y)
    local d_between_iy_y= (self.p.y-self.p.i.y)
    self.p.y= self.p.y + (dt * (math.ceil(1-(((d_between_iy_fy)-(d_between_iy_y))/(d_between_iy_fy)))+0.1) * 100)
    if (self.frame<11 or self.frame>(11+5)) then self.frame=11 end
  end

  if love.keyboard.isDown("up", "w") and self.pressed then
    if (self.frame<8 or self.frame>(8+2)) and self.jump.reached==false then self.frame=8 end

    if self.jump.reached==false then
      local d_between_iy_fy= (self.p.f.y-self.p.i.y)
      local d_between_iy_y= (self.p.y-self.p.i.y)
      self.p.y= self.p.y - (dt * math.ceil(1-(((d_between_iy_fy)-(d_between_iy_y))/(d_between_iy_fy))) * 0.75 * 100)
    end
  end

  if love.keyboard.isDown("right", "d", "left", "a") and self.pressed then
    self.vel= love.keyboard.isDown("space") and 19 or 4

    if love.keyboard.isDown("up", "w") then
      if (self.frame<8 or self.frame>(8+2)) and self.jump.reached==false then self.frame=8 end
    elseif love.keyboard.isDown("space") then
      if (self.frame<33 or self.frame>(33+7)) then self.frame= 33 end
    else
      if self.frame<17 or self.frame>(17+7) then self.frame= 17 end
    end

    if love.keyboard.isDown("left", "a") then
      if (cam.active==false and self.p.x>=(self.vel*2)) or cam.p.x==0 then self.p.x= self.p.x-mov end
      self.s.x= -math.abs(self.s.x)
    end
    if love.keyboard.isDown("right", "d") then
      if (cam.active==false or ((cam.p.x+self.p.x>=(cam.p.f.x)-1) and self.p.x<=_G.screen.w)) then self.p.x= self.p.x+mov end
      self.s.x= math.abs(self.s.x)
    end

  end

end

function player:calc_new_floor_position(new_y)
  if self.p.f.y==-100 then self.p.y= new_y end
  if ((self.p.y<=new_y+15) or self.p.f.y==-100) then self.p.f.y= new_y end
  if self.p.y>=new_y then self.p.i.y= new_y-75 end
end

function player:draw()
  love.graphics.draw(self.tileset.obj, self.tileset.tiles[self.frame], self.p.x, self.p.y, self.angle, self.s.x, self.s.y, self.tileset.tileSize.w/2, self.tileset.tileSize.h/2)
  love.graphics.draw(self.expression.tileset.obj, self.expression.tileset.tiles[self.expression.frame], 0, _G.screen.h-(self.expression.tileset.tileSize.h*1.5), 0, 1.5, 1.5)
  love.graphics.print(self.jump.reached and 'queda: verdadeiro' or 'queda: falso', 0, 0)
  love.graphics.print('altura atual: '..self.p.y, 0, 15)
  love.graphics.print('altura máxima: '..self.p.i.y, 0, 30)
  love.graphics.print('altura mínima: '..self.p.f.y, 0, 45)
  love.graphics.print('frame atual: '..self.frame, 0, 60)
end

return player