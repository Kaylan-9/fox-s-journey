local Enemy= require('models.enemy')
local metatable, Boss= {
  __index=Enemy,
  __call=function(self, boss)
    local option= _G.tbl:deepCopy(_G.options_npcs[boss.name])
    local obj= Enemy(option, boss.vel, {x= _G.map.dimensions.w-600, y= -100}, boss.messages, boss.speech_interruption, true)
    obj.s= boss.s
    obj.goto_player= true
    obj.name_music= boss.music
    obj.music= love.audio.newSource('assets/audios/'..obj.name_music, 'static')
    setmetatable(obj, {__index= self})
    return obj
  end
}, {}

setmetatable(Boss, metatable)

function Boss:trocarMusicParaAfinal()
  if _G.music~=self.music then
    _G.music:pause()
    _G.music=self.music
    _G.music:play()
  end

end

function Boss:update()
  if self then
    self.acc= self.acc + (_G.dt * math.random(1, 5))
    self.mov= (_G.dt * self.vel * 100) -- o quanto se move
    self:updateParameters()
    self:calcYPositionReferences()

    if self:playerVisible() then
      self:trocarMusicParaAfinal()
      self:chasePlayer() 
    end

    self:dying()
    if self.was_destroyed then goto continue end
    local pode_ser_hostil_e_atacado= (self.reached_the_player and not self:verSeExisteDialogoQueIterrompe() and #_G.balloon.messages==0)

    if pode_ser_hostil_e_atacado then
      self:attackPlayer()
      self:takesDamage()
    end
  end
  ::continue::
end

function Boss:keypressed(key, scancode, isrepeat)
  self:iniciarDialogo(key, scancode, isrepeat)
end

return Boss