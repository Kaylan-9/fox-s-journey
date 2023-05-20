local Tileset= require('models.tileset')
local Item= require('models.item')

local Items, metatable= {}, {
  __call= function(self, items, inventory, collectibles) -- -> pelo player, com exceção do list
    local obj= {}
    obj.options= json.import('data/options/items.json')
    obj.in_the_game_stage= {}
    obj.inventory= inventory and inventory or {}
    obj.emptying_count_inventory= 0
    obj.emptying_count_in_the_game_stage= 0
    obj.collectibles= collectibles and collectibles or {}
    obj.audio_collecting_item= love.audio.newSource('assets/audios/collecting_items.wav', 'static')
    setmetatable(obj, {__index= self})
    obj:load(items)
    return obj
  end
}

setmetatable(Items, metatable)

function Items:calcYPositionReferences(i)
  if self.in_the_game_stage[i].p.f.y==-100 then
    self.in_the_game_stage[i].p.y= self.in_the_game_stage[i].new_y end
end

function Items:load(items)
  for i=1, #items do 
    local option= _G.tbl:deepCopy(self.options[items[i].name])
    local tileset= Tileset('assets/graphics/'.._G.options_tileset[option.tileset].imgname, _G.options_tileset[option.tileset].n)
    if type(items[i].p.x)=='number' then self:create(option, tileset, items[i].p.x)
    else 
      self:createVariosDeUmaVez(option, tileset, items[i].p.xi, items[i].p.xf)
    end
  end
end

function Items:create(option, tileset, x)
  local new_item= Item(option.name, option.frame, {x=x, y=-100}, option.s, option.type, option.val_mod_em_interacao, tileset)
  new_item.new_y= 0
  table.insert(self.in_the_game_stage, new_item)
end

function Items:createVariosDeUmaVez(option, tileset, xi, xf)
  local spacing_entre_cada = tileset.tileSize.w+(tileset.tileSize.w/2)
  local num_items= (xf-xi)/spacing_entre_cada
  for i=0, num_items-1 do 
    self:create(option, tileset, xi+(i*spacing_entre_cada))
  end 
end

function Items:removeItem(indice)
  table.remove(self.in_the_game_stage, indice)
end

function Items:addToInventory(indice)
  self.emptying_count_in_the_game_stage= self.emptying_count_in_the_game_stage + 1
  local item= table.remove(self.in_the_game_stage, indice)
  table.insert(self.inventory, item)
end

function Items:addToCollectibles(indice)
  local name= self.in_the_game_stage[indice].name
  self.collectibles[name]= not self.collectibles[name] and 1 or self.collectibles[name] + 1
  self.emptying_count_in_the_game_stage= self.emptying_count_in_the_game_stage + 1
  table.remove(self.in_the_game_stage, indice)
end

function Items:drop(indice, nova_posicao)
  self.inventory[indice].p= nova_posicao
  local item= self.inventory[indice]
  table.insert(self.in_the_game_stage, item)
  table.remove(self.inventory, indice)
end

function Items:verIndiviCadaItemSeColetar(i)
  if self.in_the_game_stage[i]:playerPodeOuNaoColetar() then
    self.audio_collecting_item:play()
    if self.in_the_game_stage[i].type~='colecionável' then self:addToInventory(i)
    else self:addToCollectibles(i)
    end
  end
end 

function Items:verSeItemRestauradorFoiUsado(i)
  if self.inventory[i].type=='restaurador' then
    if self.inventory[i].activateInInventory then
      self.inventory[i]:replacePropertyValue(_G.player)
      table.remove(self.inventory, i)
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
  self.emptying_count_in_the_game_stage= 0
  for i=1, #self.in_the_game_stage do 
    self:verIndiviCadaItemSeColetar(i-self.emptying_count_in_the_game_stage) 
    if not self.in_the_game_stage[i-self.emptying_count_in_the_game_stage] then goto continue end
    self.in_the_game_stage[i-self.emptying_count_in_the_game_stage]:updateParameters()
    self:calcYPositionReferences(i-self.emptying_count_in_the_game_stage)
    ::continue::
  end
  for i=1, #self.inventory do self:verSeItemRestauradorFoiUsado(i-self.emptying_count_inventory) end
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