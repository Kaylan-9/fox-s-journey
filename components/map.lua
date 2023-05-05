local Tileset= require('components.tileset')
local map= {
  matriz= {},
  s= {x= 2, y= 2},
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
  self.tileset= Tileset('assets/graphics/tilesetOpenGame.png', {x=10, y=6}, nil, self.s)
  self.s= self.tileset.scale
  local file = io.open(filename)  
  if file~=nil then
    for line in file:lines() do
      self.matriz[#self.matriz + 1] = {}
      for j = 1, #line, 1 do self.matriz[#self.matriz][j] = line:sub(j,j) end
    end
    file:close()
  end
  self.dimensions= {
    w= #self.matriz[#self.matriz]*self.tileset.tileSize.w,
    h= #self.matriz*self.tileset.tileSize.h,
  }
  self.cam.p.i.x= (_G.screen.w/2)
  self.cam.p.f.x= (self.dimensions.w-(_G.screen.w/2))
  background:load()
end

function map:cam_movement(dt, player)
  self.cam.active= ((self.cam.p.x+player.p.x>self.cam.p.i.x) and (self.cam.p.x+player.p.x<(self.cam.p.f.x)))
  if self.cam.active==true then
    self.cam.active= true
    self.cam.acc= math.ceil(dt * player.vel * 100)

    if love.keyboard.isDown("right", "d") then
      self.cam.p.x = self.cam.p.x + self.cam.acc
      if self.cam.p.x+player.p.x>self.cam.p.f.x then
        self.cam.acc= math.ceil((self.cam.p.x+player.p.x)-self.cam.p.f.x)
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
      newy= _G.screen.h-((#self.matriz+1-i)*(self.tileset.tileSize.h))-math.abs((character_h*character_sx)/2.2)
      break
    end 
  end
  return {
    x= position.x,
    y= newy
  }
end



-- Tem o propósito de diminuir o código: serve para indicar que o símbolo na tela será renderizado como o "tile" correspondente ao id_tile (índice da tabela de tiles)

function map:tile_draw(i, j, id_tile, symbol)
  if self.matriz[i+1][j+1]==symbol then
    love.graphics.draw(
      self.tileset.obj,
      self.tileset.tiles[id_tile],
      (j*self.tileset.tileSize.w)-self.cam.p.x,
      _G.screen.h-self.dimensions.h+(i*(self.tileset.tileSize.h)),
      0,
      self.tileset.scale.x,
      self.tileset.scale.y
    ) 
  end
end

function map:draw()
  love.graphics.draw(background.img.obj, 0, 0, 0, background.s.x, background.s.y)  
  for i = 0, #self.matriz-1 do                             
    for j = 0, #self.matriz[i+1]-1 do                     
      self:tile_draw(i, j, 34, "s")
      self:tile_draw(i, j, 43, "g")
      self:tile_draw(i, j, 44, "G")
      self:tile_draw(i, j, 45, "h")
      self:tile_draw(i, j, 53, "t")
      self:tile_draw(i, j, 54, "T")
      self:tile_draw(i, j, 55, "y")
      self:tile_draw(i, j, 55, "y")
      self:tile_draw(i, j, 8, "r")
      self:tile_draw(i, j, 9, "A")
      self:tile_draw(i, j, 18, "k")
      self:tile_draw(i, j, 19, "K")
      self:tile_draw(i, j, 20, "a")
      self:tile_draw(i, j, 30, "l")
      self:tile_draw(i, j, 29, "I")
      self:tile_draw(i, j, 28, "i")
      self:tile_draw(i, j, 27, "L")
      self:tile_draw(i, j, 38, "j")
      self:tile_draw(i, j, 39, "J")
    end
  end
end

return map