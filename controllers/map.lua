local Tileset= require('models.tileset')
local Map, metatable= {}, {
  __call= function(self, filename_tileset_map, filename_map, filename_background)
    local obj= {}
    obj.options_maps= json.import('data/options/maps.json')
    obj.option_map= obj.options_maps[filename_tileset_map]
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
      for j = 1, #line do 
        self.matriz[#self.matriz][j] = line:sub(j,j) 
      end
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

function Map:camDeveSerAtiva()
  local p_inicial_min= (self:positcaoRealPlayer()>self.cam.p.i.x)
  local p_final_max= (self:positcaoRealPlayer()<(self.cam.p.f.x))
  self.cam.active= (p_inicial_min and p_final_max) and (not _G.boss.active or _G.boss.was_destroyed)
end

function Map:camMovement()
  self:camDeveSerAtiva()
  if self.cam.active then
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

function Map:tileAtualX(imaginary_px)
  return math.ceil((imaginary_px)/self.tileset.tileSize.w)
end

function Map:behaviorTileAtual(i, j, behavior)
  if self.option_map[self.matriz[i][j]]~=nil then
    return self.option_map[self.matriz[i][j]].behavior==behavior
  end
end

function Map:indicePY(i, tile_percentage)
  return #self.matriz+tile_percentage-i
end 

function Map:calcFloorTileAtual(i, j, indice_inicial, imaginary_px, character_h, character_sx)
  local reajuste_meio_personagem= math.abs((character_h*character_sx)/2.2)
  local tile_percentage= 0
  if self:behaviorTileAtual(i, j, 'floor') then tile_percentage= indice_inicial
                                                                           --1 inverte o sentido aumentando o y 
  elseif self:behaviorTileAtual(i, j, 'down_and_up') then tile_percentage= 1-(j-(imaginary_px/self.tileset.tileSize.w))
  elseif self:behaviorTileAtual(i, j, 'up_and_down') then tile_percentage= (j-(imaginary_px/self.tileset.tileSize.w))
  end

  if tile_percentage~=0 then 
    return _G.screen.h-(self:indicePY(i, tile_percentage)*(self.tileset.tileSize.h))-reajuste_meio_personagem
  end
end

function Map:positionCharacter(position, imaginary_px, character_h, character_sx)
  local indice_inicial= 1
  local new_positiony
  local j = self:tileAtualX(imaginary_px)
  for i=indice_inicial, #self.matriz do
    new_positiony= self:calcFloorTileAtual(i, j, indice_inicial, imaginary_px, character_h, character_sx)
    if new_positiony then 
      break 
    end 
  end
  return {
    x= position.x,
    y= new_positiony
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
      -- acessando configuração do tileset do mapa atual para desenhar o tile correto
      for k, v in pairs(self.option_map) do
        self:tileDraw(i, j, v.tile, k)
      end
    end
  end
end

return Map