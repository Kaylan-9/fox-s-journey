local Collision= require("useful.collision")
local Tileset= require('models.tileset')

local collision= Collision()

-- colecionável -> não é possível dropar o item: gema
-- power-up -> fica no inventário e é possível dropar
-- restaurador -> pode restaurar a vida do player quando ele quiser ele também fica no inventário
local Item, metatable= {}, {
  __call= function(self, name, frame, p, size, type, val_mod_em_interacao)
    local object= {}
    object.name= name
    object.type= type
    if object.type=='power-up' or object.type=='restaurador' then object.active= false end
    object.frame= frame
    object.s= {x= 1, y= 1}
    object.tileset= Tileset('assets/graphics/Fruits.png', {x= 4, y= 6})
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

    -- restaurador aproveitar a propriedade active para ser excluido pela classe items
    if self.type=='power-up' or self.type=='restaurador' then self.active= true end

    if self.type=='power-up' then character[key]= value
    elseif self.type=='restaurador' then character[key]= character[key] + value
    end

  end
end

function Item:playerPodeOuNaoColetar(player_position, player_raio)
  local can= false
  if collision:circle(player_position, self.p, player_raio) then
    if self.type=='colecionável' then
      can= true
    else
      if love.keyboard.isDown('l') then can= true end
    end
  end
  return can
end

function Item:draw()
  love.graphics.draw(
    self.tileset.tileset.obj,
    self.tileset.tiles[self.frame],
    self.p.x-_G.map.cam.p.x, 
    self.p.y,
    self.angle,
    self.s.x,
    self.s.y,
    self.tileset.tileSize.w/2,
    self.tileset.tileSize.h/2
  )
end

return Item