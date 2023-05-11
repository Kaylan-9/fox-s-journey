local Item, metatable= {}, {
  __call= function(self, p, size, val_somados_em_interacao, val_mod_em_interacao)
    local object= {}
    object.s= {x= 1, y= 1}
    object.p= p
    object.size= size
    object.val_somados_em_interacao= val_somados_em_interacao
    object.val_mod_em_interacao= val_mod_em_interacao
    setmetatable(object, {__index= self})
    return object
  end
}

setmetatable(Item, metatable)

-- Aplicar valor ao personagem desejado
function Item:addToPropertyValue(character)
  for key, value in pairs(self.val_somados_em_interacao) do
    character[key]= character[key] + value
  end
end

-- Substituir valor ao personagem desejado
function Item:replacePropertyValue(character)
  for key, value in pairs(self.val_mod_em_interacao) do
    character[key]= value
  end
end

function Item:draw()
  
end

return Item