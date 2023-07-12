local Player= require('obj.player')
local ObjManager= {
  objs= {},
  background_objs= {}
}

function ObjManager:addObj(obj)
  table.insert(self.objs, obj)
end
function ObjManager:removeObj(id)
  local index_of= self:indexOfObj(id)
  if type(index_of)=='number' then
    table.remove(self.objs, index_of)
  end
end
function ObjManager:indexOfObj(id)
  local index= nil
  for i, obj in pairs(self.objs) do
    if obj.id==id then
      index= i
      break
    end
  end
  return index
end

-- captura o primeiro objeto que possui o nome buscado
function ObjManager:get(name)
  local fetched_obj= false
  for _, obj in pairs(self.objs) do
    if obj.name==name then
      fetched_obj= obj
      break
    end
  end 
  return fetched_obj
end

function ObjManager:addObjBackground(obj)
  table.insert(self.background_objs, obj)
end

function ObjManager:getList(not_list)
  local objs= {}
  for _, obj in pairs(self.objs) do
    local belongs_to_list= true
    for i=1, #not_list do
      if obj.name==not_list[i] then
        belongs_to_list= false
        break
      end
    end
    if belongs_to_list then
      table.insert(objs, obj)
    end
  end
  return objs
end

function ObjManager:executeObjFunction(name_function)
  for _, background_obj in pairs(self.background_objs) do
    if type(background_obj[name_function])=='function' then
      background_obj[name_function](background_obj)
    end
  end
  for _, obj in pairs(self.objs) do
    if type(obj[name_function])=='function' then
      obj[name_function](obj)
    end
  end
end

function ObjManager:load()
  self:addObj(Player(self))
  self:executeObjFunction('load')
end

function ObjManager:update()
  self:executeObjFunction('update')
end

function ObjManager:draw()
  self:executeObjFunction('draw')
end

return ObjManager