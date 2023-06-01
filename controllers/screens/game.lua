local Screen= require('models.screen')
local Game= Screen('game')

function Game:loadButtons()
  self:newWriting('Game Over', {x= _G.screen.w/2, y= _G.screen.h/2}, {x= 4, y= 4}, false, self.enableMessage)
  self:newButtonAbaixoDoAnterior('reiniciar', self.resetGame, false, self.enableResetButton)
end 

function Game:enableResetButton()
  if _G.game.game_stage>0 and _G.player.was_destroyed then
    self.active= true
  else 
    self.active= false
  end
end

function Game:enableMessage()
  if _G.game.game_stage>0 and _G.player.was_destroyed then
    self.active= true
  else 
    self.active= false
  end
end

function Game:resetGame()
  _G.game.pause= false
  _G.game.game_stage= 0
end

-- para a Class screens avaliar se deve aparecer na tela ou não
function Game:activeWhen()
  return _G.game.game_stage>0 and _G.player.was_destroyed
end

return Game