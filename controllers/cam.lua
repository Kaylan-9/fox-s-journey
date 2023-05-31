local metatable, Cam= {
  __call=function(self)
    local obj= {}
    obj.mov_acc= 0
    setmetatable(obj, {__index= self})
    obj:setPosition(0, 0)
    return obj
  end
}, {}

setmetatable(Cam, metatable)

function Cam:setPosition(x, y)
  self.p= {i={}, f={}}
  self.player= {p= {}}
  self.p.x= x
  self.p.y= y
  self.p.i.x= (_G.screen.w/2)
  self.p.f.x= (_G.map.dimensions.w-(_G.screen.w/2))
  self.player.p.x= 0
end

function Cam:pressingRight() return love.keyboard.isDown("right", "d") end
function Cam:pressingLeft() return love.keyboard.isDown("left", "a") end

function Cam:movement()
  if self:mustMove() then
    self.mov_acc= math.ceil(_G.dt * _G.player.vel * 100)

    if self:pressingRight() then
      self.p.x= self.p.x+self.mov_acc
      if self.p.x+_G.player.p.x>self.p.f.x then
        self.mov_acc= math.ceil((self.p.x+_G.player.p.x)-self.p.f.x)
        self.p.x= self.p.x-self.mov_acc
      end
    elseif self:pressingLeft() then
      self.p.x= self.p.x-self.mov_acc

      if self.p.x<0 then self.p.x = 0 end
    end

  end
end

-- atual posição do player 
function Cam:actualPlayerPosition()
  if not _G.player.was_destroyed then
    self.player.p.x= _G.player.p.x
  end
  return self.p.x+self.player.p.x
end

-- deve movimentar a câmera?
function Cam:mustMove()
  local p_inicial_min= (self:actualPlayerPosition()>self.p.i.x)
  local p_final_max= (self:actualPlayerPosition()<(self.p.f.x))
  return (p_inicial_min and p_final_max)
end

function Cam:update()
  if not _G.player.was_destroyed then
    -- permite o personagem se mover se não há mensagens
    if (#_G.balloon.messages==0) then
      self:movement()
    end
  end 
end

return Cam