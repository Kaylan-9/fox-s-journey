local Player= require('object.player')
local ObjectManager= {
  objects= {},
  background_objects= {}
}

function ObjectManager:addObject(object)
  table.insert(self.objects, object)
end
function ObjectManager:removeObject(id)
  local index_of= self:indexOfObject(id)
  if type(index_of)=='number' then
    table.remove(self.objects, index_of)
  end
end
function ObjectManager:indexOfObject(id)
  local index= nil
  for i, object in pairs(self.objects) do
    if object.id==id then
      index= i
      break
    end
  end
  return index
end

-- captura o primeiro objeto que possui o nome buscado
function ObjectManager:get(name)
  local fetched_object= false
  for _, object in pairs(self.objects) do
    if object.name==name then
      fetched_object= object
      break
    end
  end 
  return fetched_object
end

function ObjectManager:addObjectBackground(object)
  table.insert(self.background_objects, object)
end

function ObjectManager:getList(not_list)
  local objects= {}
  for _, object in pairs(self.objects) do
    local belongs_to_list= true
    for i=1, #not_list do
      if object.name==not_list[i] then
        belongs_to_list= false
        break
      end
    end
    if belongs_to_list then
      table.insert(objects, object)
    end
  end
  return objects
end

function ObjectManager:executeObjectFunction(name_function)
  for _, background_object in pairs(self.background_objects) do
    if type(background_object[name_function])=='function' then
      background_object[name_function](background_object)
    end
  end
  for _, object in pairs(self.objects) do
    if type(object[name_function])=='function' then
      object[name_function](object)
    end
  end
end

function ObjectManager:load()
  self:addObject(Player(self))
  self:executeObjectFunction('load')
end

function ObjectManager:update()
  self:executeObjectFunction('update')
end

function ObjectManager:draw()
  self:executeObjectFunction('draw')
end

return ObjectManager