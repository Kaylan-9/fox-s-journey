local Tileset= require('models.tileset')
local Map, metatable= {}, {
  __call= function(self, filename_tileset_map, filename_map, filename_background)
    local obj= {}
    obj.matriz= {}
    obj.s= {x= 2, y= 2}
    obj.cam= {}
    obj.cam.active= false
    obj.cam.acc= 0
    obj.cam.p= {}
    obj.cam.p.x= 0
    obj.cam.p.y= 0
    obj.cam.p.i= {x= 0}
    obj.cam.p.f= {x= 0}
    obj.background= {}
    obj.background.s= {}
    obj.background.img= {}
    obj.background.img.obj= love.graphics.newImage("assets/graphics/"..filename_background)
    obj.background.img.size= {}
    obj.background.img.size.w= obj.background.img.obj:getWidth()
    obj.background.img.size.h= obj.background.img.obj:getHeight()
    setmetatable(obj, {__index= self})
    obj:backgroundLoad()
    obj:load(filename_tileset_map, filename_map)
    return obj
  end
}

setmetatable(Map, metatable)

function Map:backgroundLoad()
  if _G.screen.w>_G.screen.h then
    self.background.s.x= _G.screen.w/self.background.img.size.w
    self.background.s.y= self.background.s.x
  else
    self.background.s.x= _G.screen.h/self.background.img.size.h
    self.background.s.y= self.background.s.x
  end
end

function Map.load(self, filename_tileset_map, filename_map)
  self.tileset= Tileset('assets/graphics/'..filename_tileset_map, {x=10, y=6}, nil, self.s)
  self.s= self.tileset.scale
  local file = io.open('assets/maps/'..filename_map)  
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
end

function Map:camBloqueaNoBoss()
  if self:positcaoRealPlayer()>=(self.cam.p.f.x)-1 then
    _G.boss.active= true
  end
end

function Map:positcaoRealPlayer()
  return self.cam.p.x+_G.player.p.x
end

function Map:camMovement()
  -- variável responsável por determinar se a câmera está ativa ou não
  local p_inicial_min= (self:positcaoRealPlayer()>self.cam.p.i.x)
  local p_final_max= (self:positcaoRealPlayer()<(self.cam.p.f.x))
  self.cam.active= (p_inicial_min and p_final_max)

  -- if not _G.npcs.boss.active then
    if self.cam.active and not _G.boss.active then
      self.cam.acc= math.ceil(_G.dt * _G.player.vel * 100)

      if love.keyboard.isDown("right", "d") then
        self.cam.p.x= self.cam.p.x+self.cam.acc
        if self.cam.p.x+_G.player.p.x>self.cam.p.f.x then
          self.cam.acc= math.ceil((self.cam.p.x+_G.player.p.x)-self.cam.p.f.x)
          self.cam.p.x= self.cam.p.x-self.cam.acc
        end
      elseif love.keyboard.isDown("left", "a") then
        self.cam.p.x= self.cam.p.x-self.cam.acc
        if self.cam.p.x<0 then self.cam.p.x = 0 end
      end

    end
  -- end
end

function Map:update()
  local nao_ha_messages= (#_G.balloon.messages==0)
  -- permite o personagem se mover se não há mensagens
  if nao_ha_messages then
    self:camBloqueaNoBoss()
    self:camMovement()
    self:backgroundLoad()
  end
end

function Map:positionCharacter(position, imaginary_px, character_h, character_sx)
  local j = math.ceil((imaginary_px)/self.tileset.tileSize.w)
  local newy
  for i=1, #self.matriz do
    if self.matriz[i][j]=='G' then
      newy= _G.screen.h-((#self.matriz+1-i)*(self.tileset.tileSize.h))-math.abs((character_h*character_sx)/2.2)
      break
    elseif self.matriz[i][j]=='g' or self.matriz[i][j]=='h' then
      -- distância do começo ao fim do azulejo
      -- somando o valor decimal restante do tile como a altura em relação a distância do quadrado e inverter se a direção for oposta
      local d_from_start_tile= self.matriz[i][j]=='h' and (j-((imaginary_px)/self.tileset.tileSize.w)) or (((imaginary_px)/self.tileset.tileSize.w)-math.floor((imaginary_px)/self.tileset.tileSize.w))
      newy= _G.screen.h-((#self.matriz+(
        d_from_start_tile
      )-i)*(self.tileset.tileSize.h))-math.abs((character_h*character_sx)/2.2)
      break
    end
  end
  return {
    x= position.x,
    y= newy
  }
end

-- Tem o propósito de diminuir o código: serve para indicar que o símbolo na tela será renderizado como o "tile" correspondente ao id_tile (índice da tabela de tiles)

function Map:tileDraw(i, j, id_tile, symbol)
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

function Map:draw()
  love.graphics.draw(self.background.img.obj, 0, 0, 0, self.background.s.x, self.background.s.y)  
  for i = 0, #self.matriz-1 do                             
    for j = 0, #self.matriz[i+1]-1 do                     
      self:tileDraw(i, j, 34, "s")
      self:tileDraw(i, j, 43, "g")
      self:tileDraw(i, j, 44, "G")
      self:tileDraw(i, j, 45, "h")
      self:tileDraw(i, j, 53, "t")
      self:tileDraw(i, j, 54, "T")
      self:tileDraw(i, j, 55, "y")
      self:tileDraw(i, j, 55, "y")
      self:tileDraw(i, j, 8, "r")
      self:tileDraw(i, j, 9, "A")
      self:tileDraw(i, j, 18, "k")
      self:tileDraw(i, j, 19, "K")
      self:tileDraw(i, j, 20, "a")
      self:tileDraw(i, j, 30, "l")
      self:tileDraw(i, j, 29, "I")
      self:tileDraw(i, j, 28, "i")
      self:tileDraw(i, j, 27, "L")
      self:tileDraw(i, j, 38, "j")
      self:tileDraw(i, j, 39, "J")
    end
  end
end

return Map