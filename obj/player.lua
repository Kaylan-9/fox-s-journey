local KeyboardMouseManager= require('manager.keyboardMouseManager')
local CameraManager= require('manager.cameraManager')
local tilesManager= require('manager.tilesManager')
local LongDistanceAttack= require('obj.props.lda.long_distance_attack')

local Obj= require('obj.obj')
local Player= {}
local metatable= {
  __index= Obj,
  __call= function(self, objManager)
    local player= Obj(
      objManager,
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
        objs= objManager:getList({'fireball'})
      },
      {
        walking_speed= {min= 8, max= 18},
      }
    )
    player.ranged_attack_timer= timer:new({
      duration= 0.1,
      can_repeat= true,
      parent= self
    })
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
  self:attacking()
end

function Player:attacking()
  if KeyboardMouseManager:getKeyUsed('fireball') then self:releaseFireball() end
end

function Player:releaseFireball()
  self.ranged_attack_timer:setTimeOut({function ()
    self.objManager:addObj(LongDistanceAttack('fireball', { duration= 5 }, self))
  end})
end

function Player:update()
  self:controlling()
  self:falling()
  self:updateObjBehavior(KeyboardMouseManager:getKeyUsed('move'))
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
    if self.can_jump then
      self.physics.force_acc.y= self.physics.force_acc.y-50
      self.can_jump= false
    end
  end
end

function Player:extraDraw()
  love.graphics.print('Player')
  love.graphics.print('( x '..self.p.x..', x cam '..self.cam.x..', y '..self.p.y..' )', 0, 15)
  love.graphics.print('( force y '..self.physics.force_acc.y..')', 0, 30)
end

return Player