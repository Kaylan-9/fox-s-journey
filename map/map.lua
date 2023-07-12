local Background= require('obj.background')
local Block= require('obj.block')
local EnemyBat= require('obj.enemy.bat')
local CameraManager= require('manager.cameraManager')

local objManager= require('manager.objManager')
local Map= {}
local metatable= {
  __call= function(self)
    local map= {}
    setmetatable(map, {__index= self})
    return map
  end
}

setmetatable(Map, metatable)

function Map:loadObjs(StandardObj, args, initial_position, _repeat)
  -- adicionando objeto padrão 
  args.initial_position= initial_position
  local new_obj= StandardObj(args)
  objManager:addObj(new_obj)

  -- repetindo objeto padrão em relação a "x" e ou "y"
  if type(_repeat)=='table' then
    for n, v in pairs(_repeat) do
      if v>0 then
        for i=1, v do
          local new_position_for_duplicate_obj= tbl:deepCopy(initial_position)
          new_position_for_duplicate_obj[n]= new_position_for_duplicate_obj[n]+1+(new_obj.body[n=='x' and 'w' or 'h']*i)
          args.initial_position= new_position_for_duplicate_obj
          new_obj= StandardObj(args)
          objManager:addObj(StandardObj(args))
        end
      end
    end
  end
end

function Map:loadBackground(props)
  objManager:addObjBackground(
    Background({
      objManager= objManager,
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
    elseif n=='objs' then 
      for i=1, #v do       
        if v[i]._repeat then
          self:loadObjs(
            (v[i].type=='block' and Block),
            {
              objManager= objManager,
              move_every= v[i].move_every,
              p_reference= CameraManager:getPosition()
            },
            v[i].initial_position,
            v[i]['_repeat']
          )
        else
          objManager:addObj(Block({
            objManager= objManager,
            move_every= v[i].move_every,
            p_reference= CameraManager:getPosition(),
            initial_position= v[i].initial_position
          }))
        end
      end
    end
  end

  objManager:addObj(EnemyBat(objManager, {x=600, y=-300}, CameraManager:getPosition()))
end

return Map