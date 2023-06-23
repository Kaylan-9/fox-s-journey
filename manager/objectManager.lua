local Player= require('object.player')
local Background= require('object.background')
local Block= require('object.block')
local ObjectManager= {
  objects= {},
  background_objects= {}
}

function ObjectManager:addObject(object)
  table.insert(self.objects, object)
end

function ObjectManager:addObjectBackground(object)
  table.insert(self.background_objects, object)
end

function ObjectManager:getList(name_list)
  local objects= {}
  if name_list=='objects' then objects= self.objects
  elseif name_list=='background_objects' then objects= self.objects
  end
  return objects
end

function ObjectManager:executeObjectFunction(name_function)
  for _, background_object in pairs(self.background_objects) do background_object[name_function](background_object) end
  for _, object in pairs(self.objects) do object[name_function](object) end
end

function ObjectManager:load()
  -- self:addObjectBackground(Background())
  self:addObject(Block(0, self:getList('objects'), {x=500, y=550}))
  self:addObject(Block(1, self:getList('objects'), {x=564, y=550}))
  self:addObject(Block(2, self:getList('objects'), {x=628, y=550}))
  self:addObject(Block(3, self:getList('objects'), {x=692, y=525}))
  self:addObject(Block(4, self:getList('objects'), {x=756, y=550}))
  self:addObject(Block(5, self:getList('objects'), {x=810, y=525}))
  self:addObject(Block(6, self:getList('objects'), {x=874, y=500}))
  self:addObject(Block(7, self:getList('objects'), {x=938, y=475}))
  self:addObject(Block(8, self:getList('objects'), {x=1002, y=425}))
  self:addObject(Block(9, self:getList('objects'), {x=1066, y=375}))
  self:addObject(Player(self:getList('objects')))
end

function ObjectManager:update()
  self:executeObjectFunction('update')
end

function ObjectManager:draw()
  self:executeObjectFunction('draw')
end

return ObjectManager