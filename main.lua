
local map= require('map')
local player= require('player')
local w, h = love.graphics:getDimensions()
local values

function love.load()  
  love.graphics.setBackgroundColor(75/255, 190/255, 230/255)                          
  map:load('map.txt', w, h)   
  player:load(w, h)
end

function love.keypressed(key, scancode, isrepeat)
  player:keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

function love.keyreleased(key)
  player:keyreleased(key)
end

function love.update(dt)
  map:update(dt, w, h, player.p.x, player.vel, player.s.x)
  player:update(dt, map.cam.p, w, h)
  if player.p.f.y==-100 then 
    values= map:positionPlayer(player.p, player.img.size.h, player.s.x, h)
    player.p.y= values.y
    player.p.f.y= values.y 
  end
end

function love.draw()         
  map:draw() 
  player:draw()
end
