local Tileset= require('components.tileset')
local map= {
  matriz= {},
  cam= {
    active= false,
    acc= 0,
    p= {
      x= 0,
      y= 0,
      i= {x= 0},
      f= {x= 0}
    }
  }
}

local background= {
  s= {},
  img= {
    obj= love.graphics.newImage("assets/graphics/tilesetOpenGameBackground.png"),
    size= {}
  }
}

function background.load(self)
  self.img.size.w= self.img.obj:getWidth()
  self.img.size.h= self.img.obj:getHeight()
  if _G.screen.w>_G.screen.h then
    self.s.x= _G.screen.w/self.img.size.w
    self.s.y= self.s.x
  else
    self.s.x= _G.screen.h/self.img.size.h
    self.s.y= self.s.x
  end
end

function map.load(self, filename)
  self.tileset= Tileset('assets/graphics/tilesetOpenGame.png', {x=8, y=5})
  self.tileS= {
    x=2,
    y=2
  }
  local file = io.open(filename)  
  if file~=nil then
    for line in file:lines() do
      self.matriz[#self.matriz + 1] = {}
      for j = 1, #line, 1 do self.matriz[#self.matriz][j] = line:sub(j,j) end
    end
    file:close()
  end
  self.dimensions= {
    w= #self.matriz[#self.matriz]*32,
    h= #self.matriz*self.tileset.tileSize.h,
  }
  self.cam.p.i.x= (_G.screen.w/2)
  self.cam.p.f.x= (self.dimensions.w-(_G.screen.w/2))
  background:load()
end

function map:cam_movement(dt, player)
  self.cam.active= ((player.p.x>self.cam.p.i.x) and (self.cam.p.x+player.p.x<(self.cam.p.f.x)))
  if self.cam.active==true then
    self.cam.active= true
    self.cam.acc= (dt * player.vel * 100)

    if love.keyboard.isDown("right", "d") then
      self.cam.p.x = self.cam.p.x + self.cam.acc
      if self.cam.p.x+player.p.x>self.cam.p.f.x then
        self.cam.acc= (self.cam.p.x+player.p.x)-self.cam.p.f.x+1
        self.cam.p.x= self.cam.p.x-self.cam.acc
      end
    end

    if love.keyboard.isDown("left", "a") then
      self.cam.p.x = self.cam.p.x-self.cam.acc
      if self.cam.p.x<0 then self.cam.p.x = 0 end
    end
  end
end

function map.update(self, dt, player)
  self:cam_movement(dt, player)
  background:load()
end

function map.positionCharacter(self, position, imaginary_px, character_h, character_sx)
  local j = math.ceil((imaginary_px)/self.tileset.tileSize.w)
  local newy
  for i=1, #self.matriz do
    if self.matriz[i][j]=='G' or self.matriz[i][j]=='g' or self.matriz[i][j]=='h' then
      newy= _G.screen.h-((#self.matriz+1-i)*self.tileset.tileSize.h)-math.abs((character_h*character_sx)/2.2)
      break
    end 
  end
  return {
    x= position.x,
    y= newy
  }
end

function map.draw(self)
  love.graphics.draw(background.img.obj, 0, 0, 0, background.s.x, background.s.y)  
  love.graphics.print(self.cam.active and 'v' or 'f', 100, 450)

  for i = 1, #self.matriz, 1 do                             
    for j = 1, #self.matriz[i], 1 do                           
      if (self.matriz[i][j] == "T") then                 
        love.graphics.draw(self.tileset.obj, self.tileset.tiles[36], (j-1)*self.tileset.tileSize.w-self.cam.p.x, _G.screen.h-self.dimensions.h+((i-1)*self.tileset.tileSize.h), 0)  
      elseif (self.matriz[i][j] == "G") then             
        love.graphics.draw(self.tileset.obj, self.tileset.tiles[28], (j-1)*self.tileset.tileSize.w-self.cam.p.x, _G.screen.h-self.dimensions.h+((i-1)*self.tileset.tileSize.h), 0) 
      elseif (self.matriz[i][j] == "g") then             
        love.graphics.draw(self.tileset.obj, self.tileset.tiles[27], (j-1)*self.tileset.tileSize.w-self.cam.p.x, _G.screen.h-self.dimensions.h+((i-1)*self.tileset.tileSize.h), 0) 
      elseif (self.matriz[i][j] == "h") then             
        love.graphics.draw(self.tileset.obj, self.tileset.tiles[27], (j)*self.tileset.tileSize.w-self.cam.p.x, _G.screen.h-self.dimensions.h+((i-1)*self.tileset.tileSize.h), 0, -math.abs(1), 1) 
      elseif (self.matriz[i][j] == "t") then             
        love.graphics.draw(self.tileset.obj, self.tileset.tiles[35], (j-1)*self.tileset.tileSize.w-self.cam.p.x, _G.screen.h-self.dimensions.h+((i-1)*self.tileset.tileSize.h), 0) 
      elseif (self.matriz[i][j] == "y") then             
        love.graphics.draw(self.tileset.obj, self.tileset.tiles[35], (j)*self.tileset.tileSize.w-self.cam.p.x, _G.screen.h-self.dimensions.h+((i-1)*self.tileset.tileSize.h), 0, -math.abs(1), 1) 
      end
    end
  end
end

return map