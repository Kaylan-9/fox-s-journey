local map= {
  objs= {
    grass = love.graphics.newImage('assets/graphics/grass.png'),   
    stone = love.graphics.newImage("assets/graphics/stone.png")   
  },
  matriz= {},
  props= {
    objs= {
      size= {}
    }
  },
  cam= {
    acc= 0,
    p= {
      x= 0,
      y= 0,
      i= {x= 0},
      f= {x= 0}
    }
  },
  screen= {}
}

map.props.objs= {
  size= {
    w= map.objs.grass:getWidth(),
    h= map.objs.grass:getHeight()
  }
}

local sky= {
  s= {},
  img= {
    obj= love.graphics.newImage("assets/graphics/tilesetOpenGameBackground.png"),
    size= {}
  }
}
function map.loadBackground(self)
  sky.img.size.w= sky.img.obj:getWidth()
  sky.img.size.h= sky.img.obj:getHeight()
  if self.screen.w>self.screen.h then
    sky.s.x= self.screen.w/sky.img.size.w
    sky.s.y= sky.s.x
  else
    sky.s.x= self.screen.h/sky.img.size.h
    sky.s.y= sky.s.x
  end
end

function map.load(self, filename, w, h)  
  self.screen.w= w   
  self.screen.h= h   
  local file = io.open(filename)    
  for line in file:lines() do       
    self.matriz[#self.matriz + 1] = {}                    
    for j = 1, #line, 1 do self.matriz[#self.matriz][j] = line:sub(j,j) end                
  end
  file:close()                      
  self.dimensions= {
    w= #self.matriz[1]*self.props.objs.size.w,
    h= #self.matriz*self.props.objs.size.h,
  }
  self.cam.p.i.x= self.screen.w/2
  self.cam.p.f.x= self.dimensions.w-self.screen.w
  self:loadBackground()
end

function map.update(self, dt, w, h, player_px, player_vel, player_dir)
  self.screen.w= w
  self.screen.h= h
  if 
    (player_px+self.cam.p.x>=self.cam.p.i.x and self.cam.p.f.x-self.cam.p.x>=-1) and
    (player_px>=(self.screen.w/2)-40-player_vel and player_px<=(self.screen.w/2)+40+player_vel)
  then 
    self.cam.acc= (dt * player_vel * 100)
    if love.keyboard.isDown("right", "d") then
      self.cam.p.x = self.cam.p.x + self.cam.acc
      if self.cam.p.x+self.screen.w-self.dimensions.w>0 then self.cam.p.x = self.cam.p.x - (self.cam.p.x+self.screen.w-self.dimensions.w) end
    end
    if love.keyboard.isDown("left", "a") then
      self.cam.p.x = self.cam.p.x - self.cam.acc
      if self.cam.p.x<0 then self.cam.p.x = self.cam.p.x - self.cam.p.x end
    end
  end
  self:loadBackground()
end

function map.positionCharacter(self, position, character_h, character_sx)
  local j = math.ceil((self.cam.p.x+position.x)/self.props.objs.size.w)
  local newy
  for i=1, #map.matriz, 1 do
    if map.matriz[i][j]=='G' then
      newy= self.screen.h-((#map.matriz+1-i)*self.props.objs.size.h)-math.abs((character_h*character_sx)/2)
      break
    end 
  end
  return {
    x= position.x,
    y= newy
  }
end

function map.draw(self)
  love.graphics.draw(sky.img.obj, 0, 0, 0, sky.s.x, sky.s.y)  
  for i = 1, #self.matriz, 1 do                             
    for j = 1, #self.matriz[i], 1 do                           
      if (self.matriz[i][j] == "T") then                 
        love.graphics.draw(self.objs.stone, (j-1)*self.props.objs.size.w-self.cam.p.x, map.screen.h-map.dimensions.h+((i-1)*self.props.objs.size.h), 0)  
      elseif (self.matriz[i][j] == "G") then             
        love.graphics.draw(self.objs.grass, (j-1)*self.props.objs.size.w-self.cam.p.x, map.screen.h-map.dimensions.h+((i-1)*self.props.objs.size.h), 0) 
      end
    end
  end
end

return map