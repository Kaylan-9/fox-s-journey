local Animate= require('obj.props.animate')
local Physics= require('obj.props.physics')
local Trajectory= require('obj.props.trajectory')
local CameraManager= require('manager.cameraManager')

local Obj= {}
local metatable= {
  -- p_reference -> referência de posição
  __call=function(self, objManager, new_obj, body, initial_position, p_reference, move_every, animate, physics, trajectory)
    local obj= {}

    obj.objManager= objManager
    obj.name= new_obj.name
    obj.right_edge_image= new_obj.right_edge_image -- se é 1 a imagem aponta para a direita, caso se -1 para a esquerda
    obj.scale_factor= new_obj.scale_factor -- right_edge_image é usado para posicionar corretamente o scale_factor, ou seja ele é usado no draw
    obj.is_not_flying= true
    if obj.name=='player' then
      obj.p= {}
      obj.p.x= 0
      obj.p.y= 500
      obj.cam= initial_position
      obj.can_jump= true
    else
      obj.p= initial_position
    end

    obj.move_every= (move_every and move_every or {x= 1, y= 1})
    obj.p_reference= (p_reference and p_reference or {x= 0, y= 0})

    if body then obj.body= body end
    if trajectory then obj.trajectory= Trajectory(trajectory, obj) end
    if animate then
      if animate.tileset then
        obj.tileset= animate.tileset
        obj.animate= Animate(animate)
      else
        obj.img= animate
      end
    end

    if physics then obj.physics= Physics(physics, obj) end
    setmetatable(obj, {__index=self})
    obj.id= obj:newId()
    return obj
  end
}
setmetatable(Obj, metatable)

function Obj:generateId()
  local new_id= ''
  local chars= {'a', 'b', 'c', 'd', 'e', 'f'}
  for i=1, 9 do
    local char= math.random(0, 9+#chars)
    if char>9 then
      char= chars[char-9]
    end 
    new_id= new_id..char
  end
  return new_id
end

function Obj:newId()
  local new_id= self:generateId()
  -- local its_new= true
  -- while its_new do
  --   for _, obj in pairs(self.objManager.objs) do
  --     if obj.id==new_id then
  --       its_new= false
  --       break
  --     end
  --   end
  -- end
  return new_id
end

function Obj:getSide(name_side, position)
  local current_position= position and position or self:realPosition()
  local side= 0
  if name_side=='right' then side= current_position.x+(self.body.w/2)
  elseif name_side=='left' then side= current_position.x-(self.body.w/2)
  elseif name_side=='top' then side= current_position.y-(self.body.h/2)
  elseif name_side=='bottom' then side= current_position.y+(self.body.h/2)
  end
  return side
end

function Obj:min_cam_move(prop)
  local props= {
    x= 500,
    y= 0
  }
  return props[prop]
end

function Obj:move(prop, value)
  if value~=0 then
    if self.name=='player' then
      if prop=='x' then
        local min_cam_x_move= self:min_cam_move('x')
        if self.p.x==min_cam_x_move then
          self.cam.x= self.cam.x+value
        elseif self.p.x<min_cam_x_move then
          if self.p.x+value>min_cam_x_move then
            self.cam.x= self.p.x+value-min_cam_x_move
            self.p.x= min_cam_x_move
          elseif self.p.x+value==min_cam_x_move then
            self.p.x= min_cam_x_move
          elseif self.p.x+value<min_cam_x_move then
            self.p.x= self.p.x+value
          end
        end
        if self.cam.x<0 then
          self.p.x= self.p.x+self.cam.x
          self.cam.x= 0
        end
      elseif prop=='y' then
        self.cam.y= self.cam.y+value
      end
      return
    end
    self.p[prop]= math.ceil(self.p[prop]+value)
  end
end

function Obj:setPosition(prop, new_value)
  if self.name=='player' then

    if prop=='x' then

      local min_cam_x_move= self:min_cam_move('x')
      if new_value+self.cam.x>=min_cam_x_move then
        self.p.x= min_cam_x_move
        CameraManager:setPosition('x', new_value-min_cam_x_move+self.cam.x)
      else
        self.p.x= new_value+self.cam.x
        CameraManager:setPosition('x', 0)
      end

    elseif prop=='y' then

      CameraManager:setPosition('y', new_value-self.p.y+self.cam.y)

    end
    return
  end

  self.p[prop]= math.ceil(new_value+self.p_reference[prop]*self.move_every[prop])
end


function Obj:realPosition(prop)
  return prop and 
    math.ceil(self.p[prop]-self.p_reference[prop]*self.move_every[prop])
    or ({
      x= math.ceil(self.p.x-self.p_reference.x*self.move_every.x),
      y= math.ceil(self.p.y-self.p_reference.y*self.move_every.y)
    })
end

function Obj:updateObjBehavior(active_animation)
  if active_animation then self.animate:update(active_animation) end
  if self.trajectory then self.trajectory:update(self:realPosition()) end
  if self.physics then self.physics:update(self:realPosition()) end
end

function Obj:setPoint(name_side)
  if name_side=='left' then self.scale_factor.x= -math.abs(self.scale_factor.x)
  elseif name_side=='right' then self.scale_factor.x= math.abs(self.scale_factor.x)
  end
end

function Obj:draw()
  if self.extraDraw then self:extraDraw() end
  local current_position= self:realPosition()
  if self.tileset then
    love.graphics.draw(
      self.tileset.img,
      self.tileset.tiles[self.animate:getFrame()],
      current_position.x, current_position.y, 0,
      self.scale_factor.x*self.right_edge_image, self.scale_factor.y,
      (self.tileset.tileSize.w/2), (self.tileset.tileSize.h/2)
    )
    
  elseif self.img then
    love.graphics.draw(
      self.img,
      current_position.x, current_position.y, 0,
      self.scale_factor.x*self.right_edge_image, self.scale_factor.y,
      (self.img:getWidth()/2), (self.img:getHeight()/2)
    )
  end
  if self.body then self:lineCollisionDraw() end
end

function Obj:lineCollisionDraw()
  if self.name=='bat' or self.name=='player' then
    love.graphics.setColor(0, 0, 1)
  else 
    love.graphics.setColor(1, 0, 0)
  end
  love.graphics.polygon('line',
    self:getSide('left'), self:getSide('top'),
    self:getSide('right'), self:getSide('top'),
    self:getSide('right'), self:getSide('bottom'),
    self:getSide('left'), self:getSide('bottom')
  )
  love.graphics.setColor(1, 1, 1)
  if self.trajectory then self.trajectory:draw() end
end

return Obj