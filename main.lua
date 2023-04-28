local fullscreen, fstype= love.window.getFullscreen()
local map= require('map')
local player= require('player')
local w, h, values


function love.load()  
  love.graphics.setBackgroundColor(75/255, 190/255, 230/255)                          
  fullscreen= love.window.setFullscreen(true)
  w, h = love.graphics:getDimensions()
  map:load('map.txt', w, h)   
  player:load(w, h)
end

function love.keypressed(key, scancode, isrepeat)
  player:keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'f11' then 
    if fullscreen==false then fullscreen= love.window.setFullscreen(true)
    else fullscreen= not love.window.setFullscreen(false) end
  end
end

function love.keyreleased(key)
  player:keyreleased(key)
end

function love.update(dt)
  w, h = love.graphics:getDimensions()
  map:update(dt, w, h, player.p.x, player.vel, player.s.x)
  player:update(dt, map.cam.p, w, h)
  values= map:positionPlayer(player.p, player.img.size.h, player.s.x, h)
  player:calc_new_floor_position(values.y)
end

function love.draw()         
  map:draw() 
  player:draw()
end
