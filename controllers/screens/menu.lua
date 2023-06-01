local font= love.graphics.getFont()
local Screen= require('models.screen')
local Menu= Screen('menu')

function Menu:buttonSair()
  love.event.quit()
end

function Menu:buttonComecar()
  if self.escrito=='começar' then
    self.escrito='voltar'
    self.body.w= font:getWidth(self.escrito)
  end
  _G.game.pause= false
end

function Menu:buttonEnableSettingsScreen()
  _G.screens.current_screen= 'settings'
end

function Menu:resetGame()
  _G.game.pause= false
  _G.game.game_stage= 0
end

function Menu:enableResetButton()
  if _G.game.game_stage>0 then
    self.active= true
  else 
    self.active= false
  end
end

function Menu:loadButtons()
  self:newButton('começar', self.buttonComecar, {x= _G.screen.w/2, y= _G.screen.h/2}, nil, true)
  self:newButtonAbaixoDoAnterior('reiniciar', self.resetGame, false, self.enableResetButton)
  self:newButtonAbaixoDoAnterior('sair', self.buttonSair, true)
  self:newButtonAbaixoDoAnterior('configurações', self.buttonEnableSettingsScreen, true)
end

-- para a classe screen avaliar se deve aparecer na tela ou não
function Menu:activeWhen()
  return _G.game.pause
end

return Menu