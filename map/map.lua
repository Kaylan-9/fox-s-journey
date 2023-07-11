local Background= require('object.background')
local Block= require('object.block')
local EnemyBat= require('object.enemy.bat')
local CameraManager= require('manager.cameraManager')

local objectManager= require('manager.objectManager')
local Map= {}
local metatable= {
  __call= function(self)
    local map= {}
    setmetatable(map, {__index= self})
    return map
  end
}

setmetatable(Map, metatable)

function Map:loadObjects(StandardObject, args, initial_position, _repeat)
  -- adicionando objeto padrão 
  args.initial_position= initial_position
  local new_obj= StandardObject(args)
  objectManager:addObject(new_obj)

  -- repetindo objeto padrão em relação a "x" e ou "y"
  if type(_repeat)=='table' then
    for n, v in pairs(_repeat) do
      if v>0 then
        for i=1, v do
          local new_position_for_duplicate_object= tbl:deepCopy(initial_position)
          new_position_for_duplicate_object[n]= new_position_for_duplicate_object[n]+1+(new_obj.body[n=='x' and 'w' or 'h']*i)
          args.initial_position= new_position_for_duplicate_object
          new_obj= StandardObject(args)
          objectManager:addObject(StandardObject(args))
        end
      end
    end
  end
end

function Map:loadBackground(props)
  objectManager:addObjectBackground(
    Background({
      objectManager= objectManager,
      p_reference= CameraManager:getPosition(),
      name_img= props.name_img,
      move_every= props.move_every
    })
  )
end

function Map:load(elements)
  self.elements= elements
  for n, v in pairs(self.elements) do
    if n=='backgrounds' then for i=1, #v do self:loadBackground(v[i]) end
    elseif n=='objects' then 
      for i=1, #v do       
        if v[i]._repeat then
          self:loadObjects(
            (v[i].type=='block' and Block),
            {
              objectManager= objectManager,
              move_every= v[i].move_every,
              p_reference= CameraManager:getPosition()
            },
            v[i].initial_position,
            v[i]['_repeat']
          )
        else
          objectManager:addObject(Block({
            objectManager= objectManager,
            move_every= v[i].move_every,
            p_reference= CameraManager:getPosition(),
            initial_position= v[i].initial_position
          }))
        end
      end
    end
  end

  objectManager:addObject(EnemyBat(objectManager, {x=600, y=400}, CameraManager:getPosition()))
end

return Map