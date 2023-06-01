local font= love.graphics.getFont()
local Screen= require('models.screen')
local Settings= Screen('settings')

function Settings:buttonEnableMenuScreen()
  _G.screens.current_screen= 'menu'
end

function Settings:loadButtons()
  self:newButton('voltar ao menu', self.buttonEnableMenuScreen, {x= _G.screen.w/2, y= _G.screen.h/2}, nil, true)
  self:newButtonAbaixoDoAnterior('modo de exibição: '..self:currentView(), self.buttonSwitchViewMode, true)
end


function Settings:currentView()
  local current_view= 'janela'
  if _G.screens.fullscreen then current_view= 'tela cheia' end
  return current_view
end

function Settings:buttonSwitchViewMode()
  if not _G.screens.fullscreen then 
    _G.screens.fullscreen= love.window.setFullscreen(true)
  else 
    _G.screens.fullscreen= not love.window.setFullscreen(false) 
    love.window.setMode(800, 600, {resizable=true, minwidth=800, minheight=600})
  end
end

-- para a Class screen avaliar se deve aparecer na tela ou não
function Settings:activeWhen()
  return _G.game.pause
end

return Settings