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

function Map:loadObject(type_object, StandardObject, args, initial_position, _repeat)
  local new_obj
  if type_object=='background' then
    new_obj= StandardObject(args)
    objectManager:addObjectBackground(new_obj)
    return
  end

  -- adicionando objeto padrão 
  args.initial_position= initial_position
  new_obj= StandardObject(args)
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

function Map:load()
  objectManager:addObjectBackground(
    Background({
      objectManager= objectManager,
      name_img= 'cloud',
      move_every= {x=0.5, y=0.25},
      p_reference= CameraManager:getPosition()
    })
  )
  objectManager:addObjectBackground(
    Background({
      objectManager= objectManager,
      name_img= 'mount',
      move_every= {x=0.5, y=0.35},
      p_reference= CameraManager:getPosition()
    })
  )
  objectManager:addObjectBackground(
    Background({
      objectManager= objectManager,
      name_img= 'far_woods',
      move_every= {x=0.5, y=0.35},
      p_reference= CameraManager:getPosition()
    })
  )
  self:loadObject(
    'object',
    Block,
    {
      objectManager= objectManager,
      move_every= {x=0.5, y=0.25},
      p_reference= CameraManager:getPosition()
    },
    {x=500, y=550},
    {x=5, y=0}
  )
  objectManager:addObject(EnemyBat(objectManager, {x=600, y=400}, CameraManager:getPosition()))
end

return Map