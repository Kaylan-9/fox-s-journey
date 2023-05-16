local Item= require('models.item')

local Items, metatable= {}, {
  __call= function(self, items, inventory, collectibles) -- -> pelo player, com exceção do list
    local obj= {}
    obj.options= json.import('data/options_items.json')
    obj.in_the_game_stage= {}
    obj.inventory= {}
    obj.emptying_count_inventory= 0
    obj.collectibles= collectibles and collectibles or {}
    setmetatable(obj, {__index= self})
    --testando
    obj:load(inventory)
    return obj
  end
}

setmetatable(Items, metatable)

function Items:load(items)
  for i=1, #items do 
    local option= _G.tbl:deepCopy(self.options[items[i].name])
    local new_item= Item(option.name, option.frame, {x=1, y=1}, option.s, option.type, option.val_mod_em_interacao)
    -- testando
    table.insert(self.inventory, new_item)
  end
end

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

function Items:verIndiviCadaItemSeColetar(i)
  local player_pode_coletar= self.in_the_game_stage[i]:playerPodeOuNaoColetar()
  if player_pode_coletar then
    if not self.in_the_game_stage[i].type=='colecionável' then self:addToInventory(i)
    else self:addToCollectibles(i)
    end
  end
end 

function Items:verSeItemRestauradorFoiUsado(i)
  if self.inventory[i-self.emptying_count_inventory].type=='restaurador' then
    if self.inventory[i-self.emptying_count_inventory].activateInInventory then
      self.inventory[i-self.emptying_count_inventory]:replacePropertyValue(_G.player)
      table.remove(self.inventory, i-self.emptying_count_inventory)
      self.emptying_count_inventory= self.emptying_count_inventory + 1
    end
  end
end

function Items:verSeTeclaInventarioPress(key)
  for i=1, #self.inventory do
    if key==tostring(i) then
      if self.inventory[i].val_mod_em_interacao.life~=nil then
        local aBarraVidaVaziaSuficiente= _G.player.life+self.inventory[i].val_mod_em_interacao.life<=_G.player.maximum_life
        if aBarraVidaVaziaSuficiente then
          self.inventory[i].activateInInventory= true
          break
        end 
      end
    end
  end 
end

function Items:keypressed(key)
  self:verSeTeclaInventarioPress(key)
end

function Items:update()
  self.emptying_count_inventory= 0
  for i=1, #self.in_the_game_stage do self:verIndiviCadaItemSeColetar(i) end
  for i=1, #self.inventory do self:verSeItemRestauradorFoiUsado(i) end
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