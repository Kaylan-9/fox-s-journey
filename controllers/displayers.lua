-- todo método Displayers possui a soma do propriedade "p_incial_para_o_proximo_draw" com outro valor para indicar a posição disponível para o próximo displayer 
local font= love.graphics.getFont()
local Tileset= require('models.tileset')

local Displayers, metatable= {}, {
  __call=function(self)
    local obj= {}
    obj.props_inventory= {
      d_tile= {w= 40, h= 40}, --dimensões do tile
      spacing_tile= { w= 5, h= 5 }, --espaço entre cada tile
    }
    obj.props_collectibles= {
      spacing_tile= { w= 5, h= 5 }, --espaço entre cada tile
      s= {x= 2, y=2}
    }
    obj.options_items= json.import('data/options/items.json')
    obj.props_items= {}
    obj.props_lifeBar= {
      frame= 1,
      s= {x= 4.5, y= 4.5},
      tileset= Tileset('assets/graphics/life.png', {x=5, y=1})
    }
    obj.p_incial_para_o_proximo_draw= { w= 0, h= 0 }
    setmetatable(obj, { __index= self })
    return obj
  end
}

setmetatable(Displayers, metatable)

function Displayers:drawCollectibles()
  for k, v in pairs(self.props_items) do  
    self.p_incial_para_o_proximo_draw.w= self.p_incial_para_o_proximo_draw.w+((self.props_items[k].tileSize.w*self.props_collectibles.s.x)+self.props_collectibles.spacing_tile.w)
    love.graphics.draw(self.props_items[k].obj, self.props_items[k].tiles[self.options_items[k].frame], self.p_incial_para_o_proximo_draw.w, 0, 0,  self.props_collectibles.s.x, self.props_collectibles.s.y)
    self:gerarEscritoCollectibles(k)
  end
end

function Displayers:gerarEscritoCollectibles(key)
  local text= 'x'..tostring(_G.items.collectibles[key])
  local text_w= font:getWidth(text)
  local text_x= self.p_incial_para_o_proximo_draw.w+(self.props_items[key].tileSize.w*self.props_collectibles.s.x)
  local text_y= (self.props_items[key].tileSize.h*self.props_collectibles.s.y)/2
  love.graphics.print(text, text_x, text_y)
  self.p_incial_para_o_proximo_draw.w= self.p_incial_para_o_proximo_draw.w+(text_w)
end

function Displayers:drawInventory()
  for i=0, #_G.items.inventory-1 do 
    local xi= self.p_incial_para_o_proximo_draw.w+(i*self.props_inventory.spacing_tile.w)+(self.props_inventory.spacing_tile.w)+(i*self.props_inventory.d_tile.w)
    local yi= self.p_incial_para_o_proximo_draw.h+self.props_inventory.spacing_tile.h
    local xf= xi+self.props_inventory.d_tile.w 
    local yf= yi+self.props_inventory.d_tile.h 
    local vertices= {
      xi, yi,
      xf, yi,
      xf, yf,
      xi, yf
    }
    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon('line', vertices)
    love.graphics.setColor(1, 1, 1)
    local positionIcon= {
      x= xi+(self.props_inventory.d_tile.w/2),
      y= yi+(self.props_inventory.d_tile.h/2)
    }
    love.graphics.draw(
      _G.items.inventory[i+1].tileset.obj,
      _G.items.inventory[i+1].tileset.tiles[_G.items.inventory[i+1].frame], 
      positionIcon.x, 
      positionIcon.y, 
      0,
      1,
      1,
      (_G.items.inventory[i+1].tileset.tileSize.w/2), 
      (_G.items.inventory[i+1].tileset.tileSize.h/2)
    )
    if i==#_G.items.inventory-1 then
      self.p_incial_para_o_proximo_draw.w= self.p_incial_para_o_proximo_draw.w+xf+(self.props_inventory.spacing_tile.w)
    end
  end
end

function Displayers:drawLifeBar()
  love.graphics.draw(
    self.props_lifeBar.tileset.obj, 
    self.props_lifeBar.tileset.tiles[self.props_lifeBar.frame], 
    0, 
    0, 
    0, 
    self.props_lifeBar.s.x, 
    self.props_lifeBar.s.y
  )
  self.p_incial_para_o_proximo_draw.w= self.p_incial_para_o_proximo_draw.w+(self.props_lifeBar.tileset.tileSize.w*self.props_lifeBar.s.x)
end

function Displayers:draw()
  self:drawLifeBar()
  self:drawInventory()
  self:drawCollectibles()
end

function Displayers:atualizaTileSetListItems()
  for k, v in pairs(_G.items.collectibles) do
    self.props_items[k]= Tileset('assets/graphics/'.._G.options_tileset[self.options_items[k].tileset].imgname, _G.options_tileset[self.options_items[k].tileset].n)
  end
end

function Displayers:atualizaFrameLifeBar()
  local proporcional_ao_n_frames= ((_G.player.life*#self.props_lifeBar.tileset.tiles)/_G.player.maximum_life)
  local inverte_ordem_frames= (#self.props_lifeBar.tileset.tiles+1)
  self.props_lifeBar.frame= math.ceil(inverte_ordem_frames-proporcional_ao_n_frames)
end

function Displayers:update()
  --frame correto da barra de vida
  self:atualizaTileSetListItems()
  self:atualizaFrameLifeBar()
  self.p_incial_para_o_proximo_draw.w= 0
end

return Displayers