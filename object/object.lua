local Animate= require('animate')
local Physics= require('physics')
local Trajectory= require('trajectory')

local Object= {}
local metatable= {
  __call=function(self, name, new_object, animate, physics, trajectory)
    local object= {}
    object.name= name
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

    if trajectory then
      object.trajectory= Trajectory({
        p= object.p,
        walking_speed= trajectory.walking_speed
      })
    end

    setmetatable(object, {__index=self})
    return object
  end
}
setmetatable(Object, metatable)


function Object:getSide(name_side, position)
  local current_position= position and position or self.p
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
  if self.physics then self.physics:update(self.p) end
  if self.trajectory then self.trajectory:update(self.p) end
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
  if self.tileset then
    love.graphics.draw(
      self.tileset.img,
      self.tileset.tiles[self.animate:getFrame()],
      self.p.x, self.p.y, 0,
      self.scale_factor.x*self.right_edge_image, self.scale_factor.y,
      (self.tileset.tileSize.w/2), (self.tileset.tileSize.h/2)
    )
  elseif self.img then
    love.graphics.draw(
      self.img,
      self.p.x, self.p.y, 0,
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