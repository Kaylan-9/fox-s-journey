local Player= require('object.player')
local Background= require('object.background')
local Block= require('object.block')

local CameraManager= require('manager.cameraManager')
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

function ObjectManager:getList(name_list)
  local objects= {}
  if name_list=='objects' then objects= self.objects
  elseif name_list=='background_objects' then objects= self.objects
  elseif name_list=='no_player' then
    for _, object in pairs(self.objects) do
      if object.name~='player' then
        table.insert(objects, object)
      end
    end
  elseif name_list=='no_fireball' then
    for _, object in pairs(self.objects) do
      if object.name~='fireball' then
        table.insert(objects, object)
      end
    end
  end
  return objects
end

function ObjectManager:executeObjectFunction(name_function)
  for _, background_object in pairs(self.background_objects) do background_object[name_function](background_object) end
  for _, object in pairs(self.objects) do object[name_function](object) end
end

function ObjectManager:load()
  self:addObjectBackground(Background(self, 'cloud', {x=0.5, y=0.25}, CameraManager:getPosition()))
  self:addObjectBackground(Background(self, 'mount', {x=0.5, y=0.35}, CameraManager:getPosition()))
  self:addObjectBackground(Background(self, 'far_woods', {x=0.5, y=0.35}, CameraManager:getPosition()))
  self:addObject(Block(self, {x=500, y=550}, {x=0.5, y=0.25}, CameraManager:getPosition()))
  self:addObject(Block(self, {x=564, y=550}, {x=0.5, y=0.25}, CameraManager:getPosition()))
  self:addObject(Block(self, {x=628, y=550}, {x=0.5, y=0.25}, CameraManager:getPosition()))
  self:addObject(Block(self, {x=692, y=525}, {x=0.5, y=0.25}, CameraManager:getPosition()))
  self:addObject(Block(self, {x=756, y=550}, {x=0.5, y=0.25}, CameraManager:getPosition()))
  self:addObject(Block(self, {x=724, y=653}, {x=0.5, y=0.25}, CameraManager:getPosition()))
  self:addObject(Player(self))
end

function ObjectManager:update()
  self:executeObjectFunction('update')
end

function ObjectManager:draw()
  self:executeObjectFunction('draw')
end

return ObjectManager