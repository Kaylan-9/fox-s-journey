local Tileset= require('models.tileset')

-- colecionável -> não é possível dropar o item: gema
-- power-up -> fica no inventário e é possível dropar
-- restaurador -> pode restaurar a vida do player quando ele quiser ele também fica no inventário
local Item, metatable= {}, {
  __call= function(self, name, frame, p, s, type, val_mod_em_interacao, tileset)
    local obj= {}
    obj.name= name
    obj.type= type
    if obj.type=='power-up' or obj.type=='restaurador' then obj.activateInInventory= false end
    obj.frame= frame
    obj.s= {x= 1, y= 1}
    obj.tileset= tileset
    obj.angle= 0
    obj.p= {
      x= p.x,
      y= 0,
      f= {
        y= -100
      }
    }
    obj.s= s
    obj.val_mod_em_interacao= val_mod_em_interacao
    obj.audio_collecting_item= love.audio.newSource('assets/audios/collecting_items.wav', 'static')
    setmetatable(obj, {__index= self})
    return obj
  end
}

setmetatable(Item, metatable)

--! não utilizado ainda :construction: {
function Item:disableInInventory() self.activateInInventory= false end
function Item:activateInInventory() self.activateInInventory= true end

function Item:actualPositionInX()
  return self.observadoPelaCamera and _G.cam.p.x+self.p.x or self.p.x
end

function Item:yFromTheBottom()
  return (self.p.y-(math.abs(self.tileset.tileSize.h*self.s.x)/2))
end

function Item:updateParameters()
  _G.map:createSceneRefsItemAndInsertBehaviors(self)
end

-- Substituir valor ao personagem desejado
function Item:replacePropertyValue(character)
  for key, value in pairs(self.val_mod_em_interacao) do

    -- restaurador aproveitar a propriedade active para ser excluido pela classe items
    if self.type=='power-up' or self.type=='restaurador' then self.activateInInventory= true end

    if self.type=='power-up' then character[key]= value
    elseif self.type=='restaurador' then character[key]= character[key] + value
    end

  end
end
--! }

function Item:playerPodeOuNaoColetar()
  local can= false
  if collision:circle(_G.player.p, self.p, (_G.player.body.w/2)) then
    can= (self.type=='colecionável' or love.keyboard.isDown('f'))
  end
  if can then self.audio_collecting_item:play() end
  return can
end

function Item:draw()
  love.graphics.draw(
    self.tileset.obj,
    self.tileset.tiles[self.frame],
    self.p.x-_G.cam.p.x, 
    self.p.y,
    self.angle,
    self.s.x,
    self.s.y,
    self.tileset.tileSize.w/2,
    self.tileset.tileSize.h/2
  )
end

return Item