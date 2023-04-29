local fullscreen, fstype= love.window.getFullscreen()
local map= require('map')
local player= require('player')
local npcs= require('npcs')
local w, h


function love.load()  
  fullscreen= love.window.setFullscreen(true)
  w, h = love.graphics:getDimensions()
  map:load('map.txt', w, h)   
  player:load(w, h)
  npcs:load(w, h)
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

function reposition_y_of_npcs()
  for i=1, #npcs.on_the_screen do
    npcs:calc_new_floor_position(
      i,
      map:positionCharacter(
        npcs.on_the_screen[i].p, 
        npcs.on_the_screen[i].size.h,
        npcs.on_the_screen[i].s.x,
        npcs.h 
      ).y
    )
  end
end


function love.update(dt)
  w, h = love.graphics:getDimensions()
  map:update(dt, w, h, player.p.x, player.vel, player.s.x)
  player:update(dt, map.cam.p, w, h)
  player:calc_new_floor_position(map:positionCharacter(player.p, player.img.size.h, player.s.x, h).y)
  npcs:update(w, h)
  reposition_y_of_npcs()
end

function love.draw()         
  map:draw() 
  player:draw()
  npcs:draw()
end
