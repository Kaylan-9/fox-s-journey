local Animate= require('animate')
local Physics= require('physics')
local Trajectory= require('trajectory')

local Object= {}
local metatable= {
  -- p_reference -> referência de posição
  __call=function(self, name, new_object, animate, physics, trajectory, p_reference, move_every)
    local object= {}
    object.name= name
    object.p_reference= (p_reference and p_reference or {x= 0, y= 0})
    object.move_every= (move_every and move_every or {x= 1, y= 1})
    object.right_edge_image= new_object.right_edge_image -- se é 1 a imagem aponta para a direita, caso se -1 para a esquerda
    object.scale_factor= new_object.scale_factor -- right_edge_image é usado para posicionar corretamente o scale_factor, ou seja ele é usado no draw
    object.p= new_object.initial_position

    if animate then
      if animate.tileset then
        object.tileset= animate.tileset
        object.animate= Animate({static_frame= animate.static_frame})
      else
        object.img= animate
      end
    end

    if physics then
      object.body= physics.body
      object.physics= Physics({
        fixed= physics.fixed,
        main_object= object,
        objects= physics.objects,
        energy_preservation= physics.energy_preservation,
        mass= physics.mass
      })
    end

    setmetatable(object, {__index=self})
    if trajectory then
      object.trajectory= Trajectory({
        p= object:realPosition(),
        walking_speed= trajectory.walking_speed
      })
    end
    return object
  end
}
setmetatable(Object, metatable)

function Object:realPosition()
  return {
    x= self.p.x-mathK:around(self.p_reference.x*self.move_every.x),
    y= self.p.y-mathK:around(self.p_reference.y*self.move_every.y)
  }
end

function Object:getSide(name_side, position)
  local current_position= position and position or self:realPosition()
  local side= 0
  if name_side=='right' then side= current_position.x+(self.body.w/2)
  elseif name_side=='left' then side= current_position.x-(self.body.w/2)
  elseif name_side=='top' then side= current_position.y-(self.body.h/2)
  elseif name_side=='bottom' then side= current_position.y+(self.body.h/2)
  end
  return side
end

function Object:updateObjectBehavior(active_animation)
  self.animate:update(active_animation)
  if self.trajectory then self.trajectory:update(self:realPosition()) end
  if self.physics then self.physics:update(self:realPosition()) end
end

function Object:setPoint(name_side) 
  if name_side=='left' then
    self.scale_factor.x= -math.abs(self.scale_factor.x)
  elseif name_side=='right' then
    self.scale_factor.x= math.abs(self.scale_factor.x)
  end
end

function Object:draw()
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

function Object:lineCollisionDraw()
  love.graphics.setColor(1, 0, 0)
  love.graphics.polygon('line', self:getSide('left'), self:getSide('top'), self:getSide('right'), self:getSide('top'), self:getSide('right'), self:getSide('bottom'), self:getSide('left'), self:getSide('bottom'))
  love.graphics.setColor(1, 1, 1)
  if self.trajectory then self.trajectory:draw() end
end

return Object