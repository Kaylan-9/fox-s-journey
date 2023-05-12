local Tileset= require('models.tileset')
local Item, metatable= {}, {
  __call= function(self, frame, p, size, permanent, val_mod_em_interacao)
    local object= {}
    object.permanent= permanent
    if permanent then
      object.active= false
    end
    object.frame= frame
    object.s= {x= 1, y= 1}
    object.tileset= Tileset('assets/graphics/Vegetables.png', {x= 4, y= 6})
    object.angle= 0
    object.p= p
    object.size= size
    object.val_mod_em_interacao= val_mod_em_interacao
    setmetatable(object, {__index= self})
    return object
  end
}

setmetatable(Item, metatable)

function Item:disableInInventory() self.active= false end
function Item:activateInInventory() self.active= true end

-- Aplicar valor ao personagem desejado
function Item:addToPropertyValue(character)
  for key, value in pairs(self.val_somados_em_interacao) do
    character[key]= character[key] + value
  end
end

-- Substituir valor ao personagem desejado
function Item:replacePropertyValue(character)
  for key, value in pairs(self.val_mod_em_interacao) do
    if self.permanent then 
      character[key]= value
    end
  end
end

function Item:draw()
  love.graphics.draw(
    self.tileset.tileset.obj,
    self.tileset.tiles[self.frame],
    self.p.x, 
    self.p.y,
    self.angle,
    self.s.x,
    self.s.y,
    self.tileset.tileSize.w/2,
    self.tileset.tileSize.h/2
  )
end

return Item