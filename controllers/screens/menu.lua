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
  _G.screens.current_screen= 'game'
  _G.game.pause= false
end

function Menu:buttonEnableSettingsScreen()
  _G.screens.current_screen= 'settings'
end

function Menu:resetGame()
  _G.screens.current_screen= 'game'
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

-- redimensiona imagem para o tamanho onde o fundo mais aparece
function Menu:resizingBackground()
  self.background.s= {}
  if _G.screen.w>_G.screen.h then
    self.background.s.x= _G.screen.w/self.background.img.size.w
    self.background.s.y= self.background.s.x
  else
    self.background.s.x= _G.screen.h/self.background.img.size.h
    self.background.s.y= self.background.s.x
  end
end

function Menu:drawBeforeButtons()
  love.graphics.draw(self.background.img.obj, 0, 0, 0, self.background.s.x, self.background.s.y)  
  love.graphics.draw(self.logo.img.obj, self.logo.p.x, self.logo.p.y, 0, 1, 1, self.logo.img.size.w/2, self.logo.img.size.h/2)  
end

function Menu:settingBackground()
  self.background= {}
  self.background.img= {}
  self.background.img.size= {}
  self.background.img.obj= love.graphics.newImage("assets/graphics/tilesetOpenGameBackground.png")
  self.background.img.size.w= self.background.img.obj:getWidth()
  self.background.img.size.h= self.background.img.obj:getHeight()
  self:resizingBackground()
end

function Menu:logoSetting()
  self.logo={}
  self.logo.p= {}
  self.logo.img= {}
  self.logo.img.size= {}
  self.logo.img.obj= love.graphics.newImage("assets/graphics/logo.png")
  self.logo.img.size.w= self.logo.img.obj:getWidth()
  self.logo.img.size.h= self.logo.img.obj:getHeight()
  self.logo.p.x= (_G.screen.w/2)
  self.logo.p.y= (_G.screen.h/2)-(self.logo.img.size.w/2)
end

function Menu:repositioningElements()
  self.logo.p.x= (_G.screen.w/2)
  self.logo.p.y= (_G.screen.h/2)-(self.logo.img.size.w/2)
  self:resizingBackground()
end

function Menu:loadSpecificProperties()
  self:settingBackground()
  self:logoSetting()
end

function Menu:loadButtons()
  self:newButton('começar', self.buttonComecar, {x= _G.screen.w/2, y= _G.screen.h/2}, nil, true)
  self:newButtonAbaixoDoAnterior('reiniciar', self.resetGame, false, self.enableResetButton)
  self:newButtonAbaixoDoAnterior('configurações', self.buttonEnableSettingsScreen, true)
  self:newButtonAbaixoDoAnterior('sair', self.buttonSair, true)
end

-- para a classe screen avaliar se deve aparecer na tela ou não
function Menu:activeWhen()
  return _G.game.pause
end

return Menu