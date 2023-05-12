-- todo método Displayers possui a soma do propriedade "p_incial_para_o_proximo_draw" com outro valor para -> abaixo
-- indicar a posição disponível para o próximo displayer 
local Tileset= require('models.tileset')
local Displayers, metatable= {}, {
  __call=function(self)
    local object= {}
    object.props_invetory= {
      d_tile= {w= 40, h= 40}, --dimensões do tile
      spacing_tile= { w= 5, h= 5 }, --espaço entre cada tile
    }
    object.props_lifeBar= {
      frame= 1,
      s= {x= 4.5, y= 4.5},
      tileset= Tileset('assets/graphics/life.png', {x=5, y=1})
    }
    object.p_incial_para_o_proximo_draw= { w= 0, h= 0 }
    setmetatable(object, { __index= self })
    return object
  end
}

setmetatable(Displayers, metatable)

function Displayers:drawInventory()
  love.graphics.setColor(0, 0, 0)
  for i=0, #self.inventory-1 do 
    local xi= self.p_incial_para_o_proximo_draw.w+(i*self.props_inventory.spacing_tile.w)+(self.props_inventory.spacing_tile.w)+(i*self.props_inventory.d_tile.w)
    local yi= self.p_incial_para_o_proximo_draw.h+self.props_inventory.spacing_tile.h
    local xf= xi+self.props_inventory.d_tile.w 
    local yf= yi+self.props_inventory.d_tile.h 
    local vertices= {
      xi, yi,
      xf, yf,
      xf, yf, 
      xi, yi
    }
    love.graphics.polygon('line', vertices)
    if i==#self.inventory-1 then
      self.p_incial_para_o_proximo_draw.w= self.p_incial_para_o_proximo_draw.w+xf+self.props_inventory.spacing_tile.w
    end
  end
  love.graphics.setColor(1, 1, 1)
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
end

function Displayers:draw()
  self:drawInventory()
  self:drawLifeBar()
end

function Displayers:atualizaFrameLifeBar(life, maximum_life)
  local proporcional_ao_n_frames= ((life*#self.props_lifeBar.tileset.tiles)/maximum_life)
  local inverte_ordem_frames= (#self.props_lifeBar.tileset.tiles+1)
  self.props_lifeBar.frame= math.ceil(inverte_ordem_frames-proporcional_ao_n_frames)
end

function Displayers:update(life, maximum_life)
  --frame correto da barra de vida
  self:atualizaFrameLifeBar(life, maximum_life)
  
end

return Displayers