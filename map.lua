local map= {
  objs= {
    grass = love.graphics.newImage('grass.png'),   
    sky = love.graphics.newImage("sky.png"),            
    stone = love.graphics.newImage("stone.png")   
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
end

function map.positionPlayer(self, position, player_h, player_sx)
  local j = math.ceil((self.cam.p.x+position.x)/self.props.objs.size.w)
  local newy
  for i=1, #map.matriz, 1 do
    if map.matriz[i][j]=='G' then
      newy= self.screen.h-((#map.matriz+1-i)*self.props.objs.size.h)-math.abs((player_h*player_sx)/2)
      break
    end 
  end
  return {
    x= position.x,
    y= newy
  }
end

function map.draw(self)
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