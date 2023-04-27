local player= {
  img= {},
  quads= {},
  pressed= false,
  angle= math.rad(0),
  vel= 1,
  mov= 0,
  s= {x= 2.5, y= 2.5},
  acc= 0,
  ctrls= {
    'a', 's', 'w', 'd',
    'left', 'down', 'up', 'right',
    'space'
  },
  jump= {
    reached= false
  },
  p= {
    x= 30, 
    y= 0,
    i= {y= -100},
    f= {y= -100}
  },
  screen= {}
}

local expression= {
  img= {},
  quads= {},
  s= {x= 1.5, y= 1.5},
  frame= 1
}

player.img.obj= love.graphics.newImage('midi.png')
player.img.size= {
  w= (player.img.obj:getWidth()/16)-0.25,
  h= 32.35
}

expression.img.obj= love.graphics.newImage('sprMidiF.png')
expression.img.size= {
  w= (expression.img.obj:getWidth()/4)-1,
  h= (expression.img.obj:getHeight()/3)
}

function player.load(self, w, h) 
  self.screen.w= w
  self.screen.h= h
  for i=1, 16, 1 do 
    for j=1, 15, 1 do 
      player.quads[i+((j-1)*16)]= love.graphics.newQuad((i-1)*player.img.size.w, (j-1)*player.img.size.h, player.img.size.w, player.img.size.h, player.img.obj)
    end
  end

  for i=1, 3, 1 do 
    for j=1, 4, 1 do 
      expression.quads[i+((j-1)*4)]= love.graphics.newQuad((i-1)*expression.img.size.w, (j-1)*expression.img.size.h, expression.img.size.w, expression.img.size.h, expression.img.obj)
    end
  end
end

function player.keypressed(self, key) 
  if self.pressed~=true then
    for i=1, #self.ctrls, 1 do
      if key==self.ctrls[i] then
        self.pressed= true
        break
      end
    end
  end
end

function player.keyreleased(self, key) 
  self.pressed= false
end

function player.updateFrame(self, dt)
  local pressed= {}
  pressed.mov= love.keyboard.isDown("right", "d", "left", "a")
  pressed.run= pressed.mov and love.keyboard.isDown("space")
  pressed.jump= love.keyboard.isDown("up", "w")

  if pressed.mov or pressed.run or pressed.jump or (self.jump.reached==true) or (love.keyboard.isDown("up", "w")==false and self.p.y<self.p.f.y) then
    self.acc= self.acc+(dt * math.random(1, 5))
    if self.acc>=0.5 then
      self.frame= self.frame + 1
      self.acc= 0
    end
  else
    self.frame= 1
  end
end

function player.update(self, dt, cam_p, w, h)
  self.p.i.y= self.p.f.y-100
  self.screen.w= w
  self.screen.h= h
  self.mov= (dt * self.vel * 100)
  self:updateFrame(dt)

  if self.p.y>=self.p.f.y then self.jump.reached= false
  elseif self.p.y<=self.p.i.y then self.jump.reached= true
  end
  if (self.jump.reached==true) or (love.keyboard.isDown("up", "w")==false and self.p.y<self.p.f.y) then 
    self.p.y= self.p.y + (dt * 1 * 100) 
    if (self.frame<11 or self.frame>(11+5)) then self.frame=11 end
  end

  if love.keyboard.isDown("up", "w") and self.pressed then
    if (self.frame<8 or self.frame>(8+2)) and self.jump.reached==false then self.frame=8 end

    if self.jump.reached==false then
      self.p.y= self.p.y - (dt * 1 * 100)
    end
  end

  if love.keyboard.isDown("right", "d", "left", "a") and self.pressed then
    self.vel= love.keyboard.isDown("space") and 5 or 3
    
    if love.keyboard.isDown("up", "w") then
      if (self.frame<8 or self.frame>(8+2)) and self.jump.reached==false then self.frame=8 end
    elseif love.keyboard.isDown("space") then 
      if (self.frame<33 or self.frame>(33+7)) then self.frame= 33 end
    else 
      if self.frame<17 or self.frame>(17+7) then self.frame= 17 end
    end
    
    if love.keyboard.isDown("left", "a") then
      if 
        (self.p.x>=self.vel*2 and cam_p.x==0) or 
        (self.p.x<w+40+self.vel and self.p.x>(self.screen.w/2)+40+self.vel)
      then 
        self.p.x= self.p.x-self.mov 
      end
      self.s.x= -math.abs(self.s.x)
    elseif love.keyboard.isDown("right", "d") then
      if 
        (self.p.x>=0 and self.p.x<(w/2)+self.vel) or
        (cam_p.f.x-cam_p.x==0 and self.p.x<w-(self.vel*2))       
      then 
        self.p.x= self.p.x+self.mov 
      end
      self.s.x= math.abs(self.s.x)
    end  

  end

end

function player.draw(self)
  love.graphics.draw(self.img.obj, self.quads[self.frame], self.p.x, self.p.y, self.angle, self.s.x, self.s.y, self.img.size.w/2, self.img.size.h/2)
  love.graphics.draw(expression.img.obj, expression.quads[expression.frame], 0, self.screen.h-(expression.img.size.h*1.5), 0, 1.5, 1.5)
  love.graphics.print(self.jump.reached and 'queda: verdadeiro' or 'queda: falso', 0, 0)
  love.graphics.print('altura atual: '..self.p.y, 0, 15)
  love.graphics.print('altura máxima: '..self.p.i.y, 0, 30)
  love.graphics.print('altura mínima: '..self.p.f.y, 0, 45)
  love.graphics.print('frame atual: '..self.frame, 0, 60)
end

return player