local Items, metatable= {}, {
  __call= function(self, list, inventory, collectibles) -- -> pelo player, com exceção do list
    local object= {}
    object.in_the_game_stage= list and list or {}
    object.inventory= inventory and inventory or {}
    object.collectibles= collectibles and collectibles or {}
    setmetatable(object, {__index= self})
    return object
  end
}

setmetatable(Items, metatable)

function Items:removeItem(indice)
  table.remove(self.in_the_game_stage, indice)
end

function Items:addToInventory(indice)
  local item= self.in_the_game_stage[indice]
  table.insert(self.inventory, item)
  table.remove(self.in_the_game_stage, indice)
end

function Items:addToCollectibles(indice)
  local name= self.in_the_game_stage[indice].name
  if self.collectibles[name]~=nil then
    self.collectibles[name]= 1
  else
    self.collectibles[name]= self.collectibles[name] + 1
  end
  table.remove(self.in_the_game_stage, indice)
end

function Items:drop(indice, nova_posicao)
  self.inventory[indice].p= nova_posicao
  local item= self.inventory[indice]
  table.insert(self.in_the_game_stage, item)
  table.remove(self.inventory, indice)
end

function Items:verIndiviCadaItemSeColetar(i, player_position, player_raio)
  local player_pode_coletar= self.in_the_game_stage[i]:playerPodeOuNaoColetar(player_position, player_raio)
  if player_pode_coletar then
    if not self.in_the_game_stage[i].type=='colecionável' then self:addToInventory(i)
    else self:addToCollectibles(i)
    end
  end
end 

function Items:verSeItemRestauradorFoiUsado(i)
  if self.inventory[i].type=='restaurador' then
    if self.inventory[i].active then
      table.remove(self.inventory, i)
    end
  end
end

function Items:update(player_position, player_raio)
  for i=1, #self.in_the_game_stage do
    self:verIndiviCadaItemSeColetar(i, player_position, player_raio)
  end

  for i=1, #self.inventory do
    self:verSeItemRestauradorFoiUsado(i)
  end
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