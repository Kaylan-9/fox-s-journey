local Animate= {}
local metatable= {
  __call=function(self, new_animate)
    local animate= {}
    animate.animations= {}
    animate.frame= 1
    animate.frame_change= 0.1
    setmetatable(animate, {__index=self})
    animate:createAnimation('stopped', 'normal', new_animate.static_frame)
    animate.animation= 'stopped'
    animate.frame= animate.animations.stopped.frame
    return animate
  end
}
setmetatable(Animate, metatable)

function Animate:update(active_animation)
  if active_animation then
    self.frame=self.frame+(self.frame_change*dt*100)
    if self:getFrame()>self.animations[self.animation].frame.f then
      self.frame= self.animations[self.animation].frame.i
    end
  end
end

function Animate:movesToTheNextFrameOfTheAnimation(name_animation) -- garante que passe para o próximo frame da animação se o intervalo é da mesma animação caso contrário reinicia ela
  if self:getFrame()<self.animations[name_animation].frame.i or self:getFrame()>self.animations[name_animation].frame.f then
    self.frame= self.animations[name_animation].frame.i
  end
end

-- persistent
function Animate:setAnimation(name_animation)
  local persistent= self.animations[self.animation].type=='persistent' and (self:getFrame()==self.animations[self.animation].frame.f)
  local normal= self.animations[self.animation].type=='normal'
  if type(self.animation)=='nil' or persistent or normal then
    self.animation=name_animation
    if type(self.animations[name_animation].frame)=='table' then
      self:movesToTheNextFrameOfTheAnimation(name_animation)
    elseif type(self.animations[name_animation].frame)=='number' then
      self.frame= self.animations[name_animation].frame
    end
  end
end
function Animate:getFrame()
  return mathK:around(self.frame)
end
function Animate:createAnimation(name_animation, type_animation, frame)
  self.animations[name_animation]= {
    type= type_animation,
    frame= frame
  }
end

return Animate