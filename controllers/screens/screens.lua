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
  for k, _ in pairs(self.objs) do
    self.objs[k]:load() 
  end
end

function Screens:update() 
  for k, v in pairs(self.objs) do
    self.objs[k]:update(self.current_screen) 
  end
end

function Screens:draw() 
  for k, v in pairs(self.objs) do
    self.objs[k]:draw(self.current_screen) 
  end
end

return Screens