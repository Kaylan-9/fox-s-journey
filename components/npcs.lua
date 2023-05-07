local Character= require('components.character')

local npcs={
  options= { --cada tabela é um novo personagem para o jogo
    esqueleto= {
      name= "esqueleto",
      imgname= "skeletonBase.png",
      frame_n= {x= 10, y=6},
      frame_positions= {walking= {i=2, f=7}},
      direction= 1,
      body= {w=20, h=20}
    },
    lobo= {
      name= "lobo",
      imgname= "wolf.png",
      frame_n= {x= 5, y=8},
      frame_positions= {
        walking= {i=4, f=7},
        attacking= {i=19, f=26}
      },
      direction= -1,
      body= {w=150, h=150}
    }
  },
  on_the_screen= {}, --cada tabela é um personagem em cena
  interaction_queue= {} --a fila de NPCs com quem o personagem pode interagir
}

function npcs.create_npc(self, optioname, goto_player, vel, p, messages, s, damage, hostile)
  if(self.options[optioname]~=nil) then
    local new_character= Character(self.options[optioname], vel, p, messages, goto_player, damage, hostile)
    new_character.goto_player= goto_player
    new_character.s= s
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


function npcs:calc_new_floor_position(i, new_y)
  if self.on_the_screen[i].p.f.y==-100 then self.on_the_screen[i].p.y= new_y end
end

function npcs.load(self)
  -- self:create_npc("esqueleto", true, 2, {x=230, y=-100}, {
  --   "asddasasasasasasasasasasasasasasasdasdasdsadasd?",
  -- }, {x=2.5, y=2.5})

  self:create_npc("lobo", true, 2.5, {x=20, y=-100}, {
    "Ei humano o que faz aqui?!!!! Pera você é uma raposa de pé?"
  }, {x=0.75, y=0.75}, {attack_frame=23, value=0.05}, true)
end

function npcs:updateFrame(i, dt, player)
  if self.on_the_screen[i].animation~='' then
    self.on_the_screen[i].acc= self.on_the_screen[i].acc+(dt * math.random(1, 5))
    if self.on_the_screen[i].acc>=(0.5) then
      self.on_the_screen[i].frame= self.on_the_screen[i].frame + 1
      self.on_the_screen[i].acc= 0
    end
    if
    (self.on_the_screen[i].frame<self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].i or
    self.on_the_screen[i].frame>self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].f)
    then
      self.on_the_screen[i].frame= self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].i
    end
  end
end


-- a função abaixo serve para controlar os valores correspondentes aos npcs, como em que momento o player pode iniciar uma conversasão ou não, e também controla por exemplo até quando o esqueleto se movimentara e também a execução de sua animação
function npcs.update(self, dt, player, cam_px)
  for i=1, #self.on_the_screen do
    self.on_the_screen[i].mov= (dt * self.on_the_screen[i].vel * 100)
    if (self.on_the_screen[i].p.x-(self.on_the_screen[i].body.w/2)-cam_px>=player.p.x+player.size.w) and self.on_the_screen[i].goto_player==true then
      self.on_the_screen[i].animation= 'walking'
      self:updateFrame(i, dt)
      self.on_the_screen[i].s.x= -math.abs(self.on_the_screen[i].s.x)*self.on_the_screen[i].direction
      self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x - self.on_the_screen[i].mov)
      self.on_the_screen[i].reached_the_player= false
    elseif (self.on_the_screen[i].p.x+(self.on_the_screen[i].body.w/2)-cam_px<=player.p.x-player.size.w) and self.on_the_screen[i].goto_player==true then
      self.on_the_screen[i].animation= 'walking'
      self:updateFrame(i, dt)
      self.on_the_screen[i].s.x= math.abs(self.on_the_screen[i].s.x)*self.on_the_screen[i].direction
      self.on_the_screen[i].p.x= (self.on_the_screen[i].p.x + self.on_the_screen[i].mov)
      self.on_the_screen[i].reached_the_player= false
    else
      if self.on_the_screen[i].hostile==true then
        self.on_the_screen[i].animation= 'attacking'
        self:updateFrame(i, dt, player)
      end
      self.on_the_screen[i].reached_the_player= true
      table.insert(self.interaction_queue, i)
    end


    local emptying_count= 0
    for j=1, #self.interaction_queue do
      if self.on_the_screen[self.interaction_queue[j-emptying_count]].reached_the_player==false then
        table.remove(self.interaction_queue, j-emptying_count)
        emptying_count= emptying_count+1
      end
    end
  end
end

function npcs.draw(self, cam_px)
  self:draw_npcs_on_canvas(cam_px)
end

return npcs