_G.screen= {}
_G.screen.fullscreen, _G.screen.fstype= love.window.getFullscreen()
function _G.screen.change_resolution(self)
  if self.fullscreen==false then self.fullscreen= love.window.setFullscreen(true)
  else self.fullscreen= not love.window.setFullscreen(false) end
  self.w, self.h = love.graphics:getDimensions()
end

local balloon= require('components.balloon')
local map= require('components.map')
local player= require('components.player')
local npcs= require('components.npcs')

function love.load()  
  _G.screen:change_resolution()
  map:load('assets/maps/map.txt')   
  player:load()
  npcs:load()
  balloon:load()
end

function love.keypressed(key)
  player:keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'f11' then _G.screen:change_resolution() end
end

function love.keyreleased(key)
  player:keyreleased(key)
end

local function repositioning_characters_on_the_yaxis()
  --npcs
  for i=1, #npcs.on_the_screen do
    npcs:calc_new_floor_position(
      i,
      map:positionCharacter(
        npcs.on_the_screen[i].p, 
        (npcs.on_the_screen[i].p.x),
        npcs.on_the_screen[i].size.h,
        npcs.on_the_screen[i].s.x
      ).y
    )
  end

  --player
  player:calc_new_floor_position(
    map:positionCharacter(
      player.p, 
      (map.cam.p.x+player.p.x),
      player.size.h, 
      player.s.x
    ).y
  )
end


function love.update(dt)
  map:update(dt, player.p.x, player.vel, player.s.x)
  player:update(dt, map.cam.p)
  npcs:update(dt, {p=player.p, size=player.size}, map.cam.p.x)
  balloon:update()
  repositioning_characters_on_the_yaxis()
end

function love.draw()         
  map:draw() 
  npcs:draw(map.cam.p.x)
  player:draw()
  balloon:draw()
end
