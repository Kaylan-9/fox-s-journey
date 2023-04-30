local npcs={
  options= {},
  on_the_screen= {},
}

function npcs.separate_into_frames(self, i, size) 
  for j=1, self.options[i].frame_n.w do 
    for k=1, self.options[i].frame_n.h do 
      self.options[i].frames[j+((k-1)*self.options[i].frame_n.w)]= love.graphics.newQuad(
        (j-1)*size.w,
        (k-1)*size.h,
        size.w,
        size.h,
        self.options[i].img.size.w,
        self.options[i].img.size.h
      )
    end
  end
end

function npcs.create_option(self, name, imgname, frame_n, frame_positions)
  local i= #self.options+1
  self.options[i]= {
    s= {
      x= 2.5,
      y= 2.5
    },
    angle= 0,
    frame= 1,
    frames= {},
    name= name,
    frame_n= frame_n,
    frame_positions= frame_positions
  }
  self.options[i].img= {}
  self.options[i].img.obj= love.graphics.newImage("assets/graphics/"..imgname)
  self.options[i].img.size= {}
  self.options[i].img.size.w= self.options[i].img.obj:getWidth()
  self.options[i].img.size.h= self.options[i].img.obj:getHeight()
  self.options[i].size= {
    w= (self.options[i].img.size.w/self.options[i].frame_n.w),
    h= (self.options[i].img.size.h/self.options[i].frame_n.h)
  }
  self:separate_into_frames(i, self.options[i].size)
end

function npcs.create_npc(self, n_option, goto_player, vel, positions)
  if(self.options[n_option]~=nil) then
    local option= self.options[n_option]
    self.on_the_screen[#self.on_the_screen+1]= option
    self.on_the_screen[#self.on_the_screen].goto_player= goto_player
    self.on_the_screen[#self.on_the_screen].vel= vel
    self.on_the_screen[#self.on_the_screen].acc= 0
    self.on_the_screen[#self.on_the_screen].p= positions
    self.on_the_screen[#self.on_the_screen].p.i= {y=-100}
    self.on_the_screen[#self.on_the_screen].p.f= {y=-100}
  end
end 

function npcs.load_options(self)
  self:create_option('esqueleto', "skeletonBase.png", {w= 10, h= 6}, {
    walking= {i=2, f=7}
  })
end

function npcs.load_npcs_on_screen(self)
  self:create_npc(1, true, 3, {x=30, y=-100})
end

function npcs.draw_npcs_on_canvas(self, cam_px)
  for i=1, #self.on_the_screen do
    love.graphics.draw(
      self.on_the_screen[i].img.obj,
      self.on_the_screen[i].frames[self.on_the_screen[i].frame],
      self.on_the_screen[i].p.x-cam_px,
      self.on_the_screen[i].p.y,
      self.on_the_screen[i].angle,
      self.on_the_screen[i].s.x,
      self.on_the_screen[i].s.y,
      self.on_the_screen[i].size.w/2,
      self.on_the_screen[i].size.h/2
    )
  end
end


function npcs.calc_new_floor_position(self, i, new_y)
  if self.on_the_screen[i].p.f.y==-100 then self.on_the_screen[i].p.y= new_y end
end

function npcs.load(self)
  self:load_options()
  self:load_npcs_on_screen()
end

function npcs.updateFrame(self, i, dt)
  if self.on_the_screen[i].reached_the_player==false then
    self.on_the_screen[i].acc= self.on_the_screen[i].acc+(dt * math.random(1, 5))
    if self.on_the_screen[i].acc>=0.5 then
      self.on_the_screen[i].frame= self.on_the_screen[i].frame + 1
      self.on_the_screen[i].acc= 0
    end
    if 
      self.on_the_screen[i].goto_player==true and 
      (self.on_the_screen[i].frame<self.on_the_screen[i].frame_positions.walking.i or
      self.on_the_screen[i].frame>self.on_the_screen[i].frame_positions.walking.f) 
    then
      self.on_the_screen[i].frame= self.on_the_screen[i].frame_positions.walking.i
    end
  end
end

function npcs.update(self, dt, player, cam_px)
  for i=1, #self.on_the_screen do
    if self.on_the_screen[i].goto_player==true then
      self.on_the_screen[i].mov= (dt * self.on_the_screen[i].vel * 100)
      if (self.on_the_screen[i].p.x-cam_px>=player.p.x+player.size.w) then
        self:updateFrame(i, dt)
        self.on_the_screen[i].s.x= -math.abs(self.on_the_screen[i].s.x)
        self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x - self.on_the_screen[i].mov)
        self.on_the_screen[i].reached_the_player= false
      elseif (self.on_the_screen[i].p.x-cam_px<=player.p.x-player.size.w) then
        self:updateFrame(i, dt)
        self.on_the_screen[i].s.x= math.abs(self.on_the_screen[i].s.x)
        self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x + self.on_the_screen[i].mov)
        self.on_the_screen[i].reached_the_player= false
      else
        self.on_the_screen[i].reached_the_player= true
      end
    end
  end
end

function npcs.draw(self, cam_px)
  self:draw_npcs_on_canvas(cam_px)
  love.graphics.print(self.on_the_screen[1].frame, 0, 75)
  love.graphics.print(self.on_the_screen[1].p.x, 0, 90)
end

return npcs