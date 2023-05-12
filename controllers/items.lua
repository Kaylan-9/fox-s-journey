local Items, metatable= {}, {
  __call= function(self, list, inventory)
    local object= {}
    object.in_the_game_stage= list 
    object.inventory= inventory
    setmetatable(object, {__index= self})
    return object
  end
}

setmetatable(Items, metatable)

function Items:removeItem(indice)
  table.remove(self.list, indice)
end

function Items:addToInventory(indice)
  local item= self.list[indice]
  table.insert(self.inventory, item)
  table.remove(self.in_the_game_stage, indice)
end

function Items:drop(indice, nova_posicao)
  local item= self.inventory[indice]
  table.insert(self.in_the_game_stage, item)
  table.remove(self.inventory, indice)
end

function Items:draw()
  self:drawGameLevel()
end

function Items:drawGameLevel()
  for i=1, #self.in_the_game_stage do
    self.in_the_game_stage[i]:draw()
  end
end

return Items