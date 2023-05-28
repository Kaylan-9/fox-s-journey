_G.timer= require('useful.timer')
_G.json= require('useful.json')
_G.tbl= require('useful.tbl')
_G.collision= require('useful.collision')

_G.options_npcs= json.import('data/options/npcs.json')
_G.options_tileset= json.import('data/options/tileset.json')

local Game= require('controllers.game')
local game= Game()

function love.load()  
  game:load()
end

function love.keypressed(key, scancode, isrepeat)
  game:keypressed(key, scancode, isrepeat)
end

function love.update(dt)
  _G.dt= dt
  game:update()
end

function love.draw()         
  game:draw() 
end
