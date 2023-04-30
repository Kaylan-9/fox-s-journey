_G.screen= {}
_G.screen.fullscreen, _G.screen.fstype= love.window.getFullscreen()
function _G.screen.change_resolution(self)
  if self.fullscreen==false then self.fullscreen= love.window.setFullscreen(true)
  else self.fullscreen= not love.window.setFullscreen(false) end
  self.w, self.h = love.graphics:getDimensions()
end

local map= require('components.map')
local player= require('components.player')
local npcs= require('components.npcs')

function love.load()  
  _G.screen:change_resolution()
  map:load('assets/maps/map.txt')   
  player:load()
  npcs:load()
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
        npcs.on_the_screen[i].size.h,
        npcs.on_the_screen[i].s.x
      ).y
    )
  end

  --player
  player:calc_new_floor_position(
    map:positionCharacter(
      player.p, 
      player.size.h, 
      player.s.x
    ).y
  )
end


function love.update(dt)
  map:update(dt, player.p.x, player.vel, player.s.x)
  player:update(dt, map.cam.p)
  npcs:update()
  repositioning_characters_on_the_yaxis()
end

function love.draw()         
  map:draw() 
  player:draw()
  npcs:draw()
end
