-- A classe serve para armazenar valores importantes para a navegação entre telas e delas em si,
-- e para fornecer o método keypressed que se refere aos atalhos de teclas globais para qualquer tela

local menu= require('controllers.screens.menu')
local game= require('controllers.screens.game')
local settings= require('controllers.screens.settings')
local Screens= {
  current_screen= 'menu', -- Tela atual, propriedade que serve para indicar qual tela deve aparecer
  -- Toda tela deve ter um método activeWhen para que a classe pai de cada tela, no caso "models/screen"
  -- E cada activeWhen deve reescrever o valor current_screen quando necessário
  objs= {
    menu, 
    settings,
    game
  }
}

-- Todos os métodos abaixo serão rodados pelos mesmos de mesmo nome respectivo a cada um deles na classe game
function Screens:load() 
  self:setScreenDimensions()
  for k, _ in pairs(self.objs) do
    self.objs[k]:load() 
  end
end

function Screens:update() 
  self:updateScreenReferencesIfResized()
  for k, v in pairs(self.objs) do
    self.objs[k]:update(self.current_screen) 
  end
end

function Screens:draw() 
  for k, v in pairs(self.objs) do
    self.objs[k]:draw(self.current_screen) 
  end
end

-- método para voltar para as opções princípais do jogo
function Screens:keypressed(key)
  if key == 'escape' then 
    if self.current_screen=='menu' then
      _G.game.pause= false
      self.current_screen='game'
    elseif self.current_screen=='game' then
      _G.game.pause= true
      self.current_screen='menu'
    elseif self.current_screen=='settings' then
      self.current_screen='menu'
    end
  end
end

-- Atualiza referencias da tela se a tela é redimensionada
function Screens:updateScreenReferencesIfResized()
  if self:setScreenDimensions() then 
    if _G.map then _G.cam:setStartAndEndPosition() end
    for k, _ in pairs(self.objs) do 
      self.objs[k]:updateButtonPositions()
      if self.objs[k].repositioningElements then self.objs[k]:repositioningElements() end
    end 
  end
end

-- Responsável por armazenar as dimensões da tela para serem utilizados por todo o jogo como uma variável de ambiente
-- Esse método é aproveitado para verificar se é necessário atualizar as dimensões da tela, e retorna true se foi um caso de sucesso
function Screens:setScreenDimensions()
  -- Se não existe a variável de ambiente ela é criada e o código não executa o trecho abaixo
  if type(_G.screen)~='table' then
    _G.screen= {
      w= love.graphics.getWidth(),
      h= love.graphics.getHeight()
    }
    return true
  end

  -- Caso contrário o código armazena as dimensões atuais da janela e as estruturas condicionais se uma é acionada ou se são acionadas determinam que houve alteração das dimensões
  local update_dimensions_w, update_dimensions_h= false, false
  local current_width, current_height= love.graphics.getDimensions()
  if _G.screen.w~=current_width then 
    _G.screen.w= current_width 
    update_dimensions_w= true
  end
  if _G.screen.h~=current_height then 
    _G.screen.h= current_height 
    update_dimensions_h= true
  end

  return update_dimensions_w or update_dimensions_h
end

return Screens