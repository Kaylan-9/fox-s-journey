local Map= require('controllers.map')
local Displayers= require('controllers.displayers')
local Items= require('controllers.items')
local NPCs= require('controllers.npcs')
local Boss= require('controllers.boss')
local Balloon= require('controllers.balloon')
local Player= require('controllers.player')
local Cam= require('controllers.cam')
local mainFont= love.graphics.newFont('assets/PixelifySans-Black.otf', 13)

_G.screens= require('controllers.screens.screens')

-- Classe que vai carregar tudo o que será necessário para o jogo rodar
local metatable, Game= {
  __call=function(self)
    local obj= {}
    setmetatable(obj, {__index=self})
    _G.fullscreen, _G.fstype= love.window.getFullscreen() -- verifica se está em tela cheia
    _G.dt= 0 -- variável ambiente para o dt presente no update para não precisar passar como parâmetro de cada update (para poluir menos o código)
    obj.fases= json.import('data/fases.json') -- carrega as informações das fases, além desse arquivo há o arquivo "data/options/maps.json" que será usado para carregar as informações do tileset e qual tile o específico símbolo no seu arquivo "map" apresentará na tela (uma forma de reutilizar símbolos para outros tilesets de mapa)
    obj.game_stage= 0 -- fase atual, com base no indice do arquivo "data/fases.json", o 0 indica nenhuma fase
    obj.pause= true -- propriedade para determinar 
    obj.timer_fim_fase= timer:new(1) -- Um timer criado a classe timer, presente na pasta "useful", esse timer serve para esperar 1 segundo após o termino da fase
    setmetatable(obj, {__index= self})
    obj:setScreen()
    return obj 
  end 
}, {}

setmetatable(Game, metatable)

-- Responsável por armazenar as dimensões da tela para serem utilizados por todo o jogo como uma variável de ambiente
function Game:setScreen()
  _G.screen= {
    w= love.graphics.getWidth(),
    h= love.graphics.getHeight()
  }
end

-- Serve para atualizar o número da fase e o que será carregado em tela, a propriedade fases serve fornecer as configurações da fase que não se referem ao Tileset dela (para isso há o arquivo "data/fases.json")
function Game:nextLevel()
  if self.game_stage<#self.fases then
    self.game_stage= self.game_stage + 1
    self.fase= self.fases[self.game_stage]
  end
end 

-- Inicia a música padrão de fundo
function Game:loadMusic()
  self.name_music= self.fases[self.game_stage].music
  if _G.music then _G.music:pause() end
  _G.music= love.audio.newSource('assets/audios/'..self.name_music, 'static')
  music:play()
  music:setLooping(true)
end


--  Serve para reiniciar as classes controladoras e recarrega-las com novos valores em suas variáveis de ambiente
function Game:loadLevel()
  self:loadMusic()
  self:loadItems()
  _G.map= Map(self.fase.map) 
  _G.cam= Cam() -- Carrega classe responsável pelo movimento de câmera
  if type(self.fase.boss.name)=='string' then _G.boss= Boss(self.fase.boss) end -- Verifica se existe um boss na fase, e carrega a classe dele na variável de ambiente boss
  _G.npcs= NPCs(self.fase.npcs) -- Carrega c classe responsável por controlar o fluxo de execução dos NPCs
  _G.displayers= Displayers() -- Carrega a classe responsável por mostrar informações do player como barra de vida (que acessa a propriedade life na classe filha da classe Character, a classe Player)
  _G.balloon= Balloon() -- Carrega a classe que é responsável pelos os balões de falas dos outros personagens
  _G.player= Player() 
end 

-- Carregado no método loadLevel, o método serve para iniciar a Classe Items e carregar o inventário obtido em fases anteriores
function Game:loadItems()
  local inventory, collectibles= {}, {}
  if _G.items then inventory, collectibles= _G.items.inventory, _G.items.collectibles end
  _G.items= Items(self.fase.items, inventory, collectibles)
end


-- Na classe menu e gameover são criados métodos que reescrevem a variável game_stage com valor 0 para reiniciar o jogo, e esse método também é usado para começar o jogo, pois ele está presente no método 
function Game:reset()
  if self.game_stage==0 then
    self:nextLevel()
    self:loadLevel()
  end
end

-- Carrega no arquivo princípal de execução o "main.lua" e também outras 
function Game:load()
  love.graphics.setFont(mainFont)
  love.graphics.setDefaultFilter("nearest", "nearest") 
  screens:load() -- carrega as configurações de todas as telas por meio da classe intermediária screens presente na pasta "controllers/screens" junto das classes das respectivas telas
  love.audio.setVolume(0.1)
end


-- Carrega no arquivo princípal de execução o "main.lua", 
-- E verificar se o jogo entrará em execução, executando métodos diferentes dependendo de seu estado
function Game:update()
  screens:update()
  if self.pause==false then self:running()
  else self:paused()
  end
end

-- Executa os métodos para o jogo funcionar quando não estiver pausado, carregando também todas as classes controladoras que tem um método update
-- Além disso o método possui vários "ifs" com o intuito de prevenir que os métodos dentro de cada update acessem valores vázios,
-- pois quando um personagem morre todas as suas propriedades são apagadas recebendo uma nova chamada "was_destroyed", isso é tratada aqui e também na classe NPCs que gerencia os personagens da fase
function Game:running()
  self:reset()
  displayers:update()
  if not _G.player.was_destroyed then 
    player:update() 
    npcs:update()
    if not boss.was_destroyed then boss:update() end
  end
  items:update()
  map:update()
  balloon:update()
  _G.cam:update()
  if music then music:play() end
  self:levelEnded()
end

-- Executa todos os métodos necessários para pausar o jogo, verificando se eles ainda existem
function Game:paused()
  if npcs then npcs:pauseAudios() end
  if player and not player.was_destroyed then player:pauseAudios() end
  if boss and not boss.was_destroyed then boss:pauseAudios() end
  if music then music:pause() end
end

-- Executa os métodos de draw para as classes necessárias
function Game:draw()
  if self.pause==false then
    if map then map:draw() end
    npcs:draw()
    if not boss.was_destroyed then boss:draw() end
    items:draw()
    if not player.was_destroyed then player:draw() end
    balloon:draw()
    displayers:draw()
  end
  screens:draw()
end

-- Algumas classes possuem o método keypressed, eles são chamados aqui
function Game:keypressed(key, scancode, isrepeat)
  self:controlesTela(key)
  if self.pause==false then
    items:keypressed(key)
    if not boss.was_destroyed then boss:keypressed(key, scancode, isrepeat) end
    npcs:keypressed(key, scancode, isrepeat)
    if not _G.player.was_destroyed then player:keypressed(key, scancode, isrepeat) end
  end
end

-- Controles para a tela 
function Game:controlesTela(key)
  if key == 'escape' then self.pause= not self.pause
  elseif key == 'f11' then self:alternarResolucao() 
  end
end

-- Retorna as condições para ir para o próximo nível
function Game:parametersToGoToNextStage()
  local boss_morto= _G.boss.was_destroyed
  local zero_npcs= #_G.npcs.on_the_screen==0 and boss_morto
  return (zero_npcs and _G.player:frameAoTerminarFase())
end 

-- Método responsável por verificar se a fase termina 
function Game:levelEnded()
  if self:parametersToGoToNextStage() then
    self.timer_fim_fase:start()
    if self.timer_fim_fase:finish() then  
      self.timer_fim_fase:reset()
      self:nextLevel()
      self:loadLevel()
    end
  end
end


function Game:alternarResolucao()
  if not self.fullscreen then self.fullscreen= love.window.setFullscreen(true)
  else self.fullscreen= not love.window.setFullscreen(false) 
  end
  self:setScreen()
end

return Game