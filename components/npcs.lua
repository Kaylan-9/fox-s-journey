local Character= require('components.character')
local npcs={
  options= { --cada tabela é um novo personagem para o jogo
    esqueleto= {
      name= "esqueleto",
      imgname= "skeletonBase.png",
      frame_n= {x= 10, y=6},
      frame_positions= {walking= {i=2, f=7}}
    }
  },
  on_the_screen= {} --cada tabela é um personagem em cena
}

function npcs.create_npc(self, optioname, goto_player, vel, p)
  if(self.options[optioname]~=nil) then
    local new_character= Character(self.options[optioname], vel, p)
    new_character.goto_player= goto_player
    table.insert(self.on_the_screen, new_character) --adiciona personagem em cena
  end
end 

function npcs.draw_npcs_on_canvas(self, cam_px)
  for i=1, #self.on_the_screen do
    love.graphics.draw(
      self.on_the_screen[i].tileset.obj,
      self.on_the_screen[i].tileset.tiles[self.on_the_screen[i].frame],
      self.on_the_screen[i].p.x-cam_px,
      self.on_the_screen[i].p.y,
      self.on_the_screen[i].angle,
      self.on_the_screen[i].s.x,
      self.on_the_screen[i].s.y,
      self.on_the_screen[i].tileset.tileSize.w/2,
      self.on_the_screen[i].tileset.tileSize.h/2
    )
  end
end


function npcs.calc_new_floor_position(self, i, new_y)
  if self.on_the_screen[i].p.f.y==-100 then self.on_the_screen[i].p.y= new_y end
end

function npcs.load(self)
  self:create_npc("esqueleto", true, 3, {x=30, y=-100})
  self:create_npc("esqueleto", true, 2, {x=230, y=-100})
  self:create_npc("esqueleto", true, 5, {x=430, y=-100})
  self:create_npc("esqueleto", true, 1, {x=630, y=-100})
end

function npcs.updateFrame(self, i, dt)
  if self.on_the_screen[i].reached_the_player==false then
    self.on_the_screen[i].acc= self.on_the_screen[i].acc+(dt * math.random(1, 5))
    if self.on_the_screen[i].acc>=0.5 then
      self.on_the_screen[i].frame= self.on_the_screen[i].frame + 1
      self.on_the_screen[i].acc= 0
    end
    if 
      self.on_the_screen[i].goto_player==true and 
      (self.on_the_screen[i].frame<self.on_the_screen[i].frame_positions.walking.i or
      self.on_the_screen[i].frame>self.on_the_screen[i].frame_positions.walking.f) 
    then
      self.on_the_screen[i].frame= self.on_the_screen[i].frame_positions.walking.i
    end
  end
end

function npcs.update(self, dt, player, cam_px)
  for i=1, #self.on_the_screen do
    if self.on_the_screen[i].goto_player==true then
      self.on_the_screen[i].mov= (dt * self.on_the_screen[i].vel * 100)
      if (self.on_the_screen[i].p.x-cam_px>=player.p.x+player.size.w) then
        self:updateFrame(i, dt)
        self.on_the_screen[i].s.x= -math.abs(self.on_the_screen[i].s.x)
        self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x - self.on_the_screen[i].mov)
        self.on_the_screen[i].reached_the_player= false
      elseif (self.on_the_screen[i].p.x-cam_px<=player.p.x-player.size.w) then
        self:updateFrame(i, dt)
        self.on_the_screen[i].s.x= math.abs(self.on_the_screen[i].s.x)
        self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x + self.on_the_screen[i].mov)
        self.on_the_screen[i].reached_the_player= false
      else
        self.on_the_screen[i].reached_the_player= true
      end
    end
  end
end

function npcs.draw(self, cam_px)
  self:draw_npcs_on_canvas(cam_px)
end

return npcs