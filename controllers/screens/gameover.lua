local Screen= require('models.screen')
local GameOver= Screen()

function GameOver:loadButtons()
  self:newWriting('Game Over', {x= _G.screen.w/2, y= _G.screen.h/2}, {x= 4, y= 4}, false, self.enableMessage)
  self:newButtonAbaixoDoAnterior('reiniciar', self.resetGame, false, self.enableResetButton)
end 

function GameOver:enableResetButton()
  if _G.game.game_stage>0 and _G.player.was_destroyed then
    self.active= true
  else 
    self.active= false
  end
end

function GameOver:enableMessage()
  if _G.game.game_stage>0 and _G.player.was_destroyed then
    self.active= true
  else 
    self.active= false
  end
end

function GameOver:resetGame()
  _G.game.pause= false
  _G.game.game_stage= 0
end

-- para a Class screens avaliar se deve aparecer na tela ou não
function GameOver:activeWhen()
  return _G.game.game_stage>0 and _G.player.was_destroyed
end

return GameOver