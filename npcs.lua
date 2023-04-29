local npcs={
  options= {},
  on_the_screen= {},
  screen= {}
}

function npcs.separate_into_frames(self, i, size) 
  for j=1, self.options[i].frame_n.w do 
    for k=1, self.options[i].frame_n.h do 
      self.options[i].frames[j+((k-1)*self.options[i].frame_n.w)]= love.graphics.newQuad((j-1)*size.w, (k-1)*size.h, size.w, size.h, self.options[i].img.obj)
    end
  end
end

function npcs.create_option(self, name, imgname, frame_n)
  local i= #self.options+1
  self.options[i]= {
    p= {
      x= math.random(30, self.screen.w-30), 
      y= 0,
      i= {y= -100},
      f= {y= -100}
    },
    s= {
      x= 2.5,
      y= 2.5
    },
    angle= 0,
    frame= 1,
    frames= {},
    name= name,
    frame_n= frame_n
  }
  self.options[i].img= {}
  self.options[i].img.obj= love.graphics.newImage(imgname)
  self.options[i].img.size= {}
  self.options[i].img.size.w= self.options[i].img.obj:getWidth()
  self.options[i].img.size.h= self.options[i].img.obj:getHeight()
  self.options[i].size= {
    w= (self.options[i].img.size.w/self.options[i].frame_n.w),
    h= (self.options[i].img.size.h/self.options[i].frame_n.h)
  }
  self:separate_into_frames(i, self.options[i].size)
end

function npcs.create_npc(self, n_option)
  if(self.options[n_option]~=nil) then
    self.on_the_screen[#self.on_the_screen+1]= self.options[n_option]
  end
end 

function npcs.load_options(self)
  self:create_option('esqueleto', "skeletonBase.png", {w= 10, h= 6})
end

function npcs.load_npcs_on_screen(self)
  self:create_npc(1)
end

function npcs.draw_npcs_on_canvas(self)
  for i=1, #self.on_the_screen do
    love.graphics.draw(
      self.on_the_screen[i].img.obj,
      self.on_the_screen[i].frames[self.on_the_screen[i].frame],
      self.on_the_screen[i].p.x,
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

function npcs.load(self, w, h)
  self.screen= {
    w= w,
    h= h
  }
  self:load_options()
  self:load_npcs_on_screen()
end

function npcs.update(self, w, h)
  self.screen= {
    w= w,
    h= h
  }
end

function npcs.draw(self)
  self:draw_npcs_on_canvas()
  love.graphics.print(self.on_the_screen[1].frame, 0, 75)
end

return npcs