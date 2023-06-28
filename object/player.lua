local KeyboardMouseManager= require('manager.keyboardMouseManager')
local CameraManager= require('manager.cameraManager')
local tilesManager= require('manager.tilesManager')
local Object= require('object.object')
local Player= {}
local metatable= {
  __index= Object,
  __call= function(self, objects)
    local player= Object(
      {
        name= 'player',
        right_edge_image= 1,
        scale_factor= {x= 2, y= 2},
      },
      {
        w= 32,
        h= 55
      },
      CameraManager:getPosition(),
      nil,
      nil,
      {
        static_frame= 1,
        tileset= tilesManager:get('player')
      },
      {
        energy_preservation= 0.44,
        mass= 3.5,
        fixed= false,
        objects= objects
      },
      {
        walking_speed= {min= 8, max= 18},
      }
    )
    setmetatable(player, {__index= self})
    player:loadAnimationSettings()
    return player
  end
}
setmetatable(Player, metatable)

function Player:loadAnimationSettings()
  self.animate:createAnimation('walking', 'normal', {i=17, f=24})
  self.animate:createAnimation('running', 'normal', {i=33, f=40})
  self.animate:createAnimation('jumping', 'normal', {i=9, f=11})
  self.animate:createAnimation('falling', 'normal', {i=12, f=16})
end

function Player:controlling()
  self:running()
  self:walking()
  self:jumping()
end

function Player:update()
  self:controlling()
  self:falling()
  self:updateObjectBehavior(KeyboardMouseManager:getKeyUsed('move'))
end

function Player:running()
  self.trajectory.current_walking_speed= (KeyboardMouseManager:getKeyUsed('run') and self.trajectory.walking_speed.max or self.trajectory.walking_speed.min)
end
function Player:walking()
  if KeyboardMouseManager:getKeyUsed('left') or KeyboardMouseManager:getKeyUsed('right') then self.animate:setAnimation('walking')
  elseif KeyboardMouseManager:getKeyUsed('run') then self.animate:setAnimation('running')
  end
  if KeyboardMouseManager:getKeyUsed('left') then
    self:setPoint('left')
    self.trajectory:setCurrentMovement('x' ,-self.trajectory.current_walking_speed*dt*100)
  elseif KeyboardMouseManager:getKeyUsed('right') then
    self:setPoint('right')
    self.trajectory:setCurrentMovement('x', self.trajectory.current_walking_speed*dt*100)
  end
end

function Player:falling()
  if mathK:around(self.physics.force_acc.y)>0 then
    self.animate:setAnimation('falling')
  elseif mathK:around(self.physics.force_acc.y)<0 then
    self.animate:setAnimation('jumping')
  else
    if not KeyboardMouseManager:getKeyUsed('move') then
      self.animate:setAnimation('stopped')
    end
  end
end

function Player:jumping()
  if KeyboardMouseManager:getKeyUsed('jump') then
    if self.physics.force_acc.y>-6 then
      self.physics.force_acc.y= self.physics.force_acc.y-2
    end
  end
end

function Player:extraDraw()
  love.graphics.print('Player')
  love.graphics.print('( x '..self.p.x..', x cam '..self.cam.x..', y '..self.p.y..' )', 0, 15)
  love.graphics.print('( force y '..self.physics.force_acc.y..')', 0, 30)
end

return Player