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
local collision= require('components.collision')

function love.load()  
  love.graphics.setDefaultFilter("nearest", "nearest")
  _G.screen:change_resolution()
  map:load('assets/maps/map.txt')
  npcs:load()
  balloon:load()
end

function love.keypressed(key)
  player:keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'f11' then _G.screen:change_resolution() 
  elseif key == 'f' then 
    if #balloon.messages==0 then
      if #npcs.interaction_queue>0 then
        balloon.messages= npcs.on_the_screen[npcs.interaction_queue[1]].messages
      end
    else
      if balloon.i<#balloon.messages then 
        balloon.i= balloon.i+1
      else 
        balloon.messages= {}
        balloon.i= 1
      end
    end
  end
end

function love.keyreleased()
  player:keyreleased()
end

local function repositioning_characters_on_the_yaxis()
  -- npcs
  for i=1, #npcs.on_the_screen do
    npcs:calc_new_floor_position(
      i,
      map:positionCharacter(
        npcs.on_the_screen[i].p, 
        (npcs.on_the_screen[i].p.x),
        npcs.on_the_screen[i].tileset.tileSize.h,
        npcs.on_the_screen[i].s.x
      ).y
    )
  end

  -- player
  player:calc_new_floor_position(
    map:positionCharacter(
      player.p, 
      (map.cam.p.x+player.p.x),
      player.tileset.tileSize.h, 
      player.s.x
    ).y
  )
end

local function npc_deals_damage()
  for i=1, #npcs.on_the_screen do
    if npcs.on_the_screen[i].hostile==true then
      if collision:ellipse(player.p, npcs.on_the_screen[i].p, (npcs.on_the_screen[i].body.w/2), (npcs.on_the_screen[i].body.h/2), (npcs.on_the_screen[i].body.w/2)) then
        if npcs.on_the_screen[i].damage.attack_frame==npcs.on_the_screen[i].frame then
          player.life= player.life-npcs.on_the_screen[i].damage.value
        end
      end
    end
  end
end

function love.update(dt)
  map:update(dt, {p=player.p, vel=player.vel}, #balloon.messages==0)
  player:update(dt, map.cam, #balloon.messages==0)
  npcs:update(dt, {p=player.p, size=player.tileset.tileSize}, map.cam.p.x)
  balloon:update()
  npc_deals_damage()
  repositioning_characters_on_the_yaxis()
end

function love.draw()         
  map:draw() 
  player:draw()
  npcs:draw(map.cam.p.x)
  balloon:draw()
end
