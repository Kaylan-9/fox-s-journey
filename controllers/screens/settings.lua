local font= love.graphics.getFont()
local Screen= require('models.screen')
local Settings= Screen('settings')

function Settings:buttonEnableMenuScreen()
  _G.screens.current_screen= 'menu'
end

function Settings:loadButtons()
  self:newButton('voltar ao menu', self.buttonEnableMenuScreen, {x= _G.screen.w/2, y= _G.screen.h/2}, nil, true)
end

-- para a Class screen avaliar se deve aparecer na tela ou não
function Settings:activeWhen()
  return _G.game.pause
end

return Settings