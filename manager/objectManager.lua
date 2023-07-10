local Player= require('object.player')
local Background= require('object.background')
local Block= require('object.block')
local EnemyBat= require('object.enemys.bat')

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
  self:addObject(EnemyBat(self, {x=600, y=400}, CameraManager:getPosition()))
  self:addObject(Player(self))
end

function ObjectManager:update()
  self:executeObjectFunction('update')
end

function ObjectManager:draw()
  self:executeObjectFunction('draw')
end

return ObjectManager