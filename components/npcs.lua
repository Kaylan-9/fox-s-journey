local Character= require('models.character')

local npcs={
  options= { --cada tabela é um novo personagem para o jogo
    esqueleto= {
      name= "esqueleto",
      imgname= "skeletonBase.png",
      frame_n= {x= 10, y=6},
      frame_positions= {walking= {i=2, f=7, until_finished=false}},
      direction= 1,
      body= {w=20, h=20}
    },
    lobo= {
      name= "lobo",
      imgname= "wolf.png",
      frame_n= {x= 5, y=8},
      frame_positions= {
        walking= {i=4, f=7, until_finished=false},
        attacking= {i=19, f=26, until_finished=true}
      },
      direction= -1,
      body= {w=150, h=150}
    }
  },
  on_the_screen= {}, --cada tabela é um personagem em cena
  interaction_queue= {} --a fila de NPCs com quem o personagem pode interagir
}

function npcs.create_npc(self, optioname, goto_player, vel, p, messages, s, hostile, damage)
  if(self.options[optioname]~=nil) then
    local new_character= Character(self.options[optioname], vel, p, messages, hostile, damage)
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
  -- self:create_npc("esqueleto", true, 2, {x=230, y=-100}, {"asddasasasasasasasasasasasasasasasdasdasdsadasd?"}, {x=2.5, y=2.5}, false)
  -- self:create_npc("lobo", true, 2.5, {x=20, y=-100}, {"Ei humano o que faz aqui?!!!! Pera você é uma raposa de pé?"}, {x=0.75, y=0.75}, true, {attack_frame=23, value=0.05})
  -- self:create_npc("lobo", true, 1.75, {x=110, y=-100}, {"Ei humano o que faz aqui?!!!! Pera você é uma raposa de pé?"}, {x=0.75, y=0.75}, true, {attack_frame=23, value=0.05})
  self:create_npc("lobo", true, 2.25, {x=150, y=-100}, {"Ei humano o que faz aqui?!!!! Pera você é uma raposa de pé?"}, {x=0.75, y=0.75}, true, {attack_frame=23, value=0.05})
  -- self:create_npc("lobo", true, 2.15, {x=225, y=-100}, {"Ei humano o que faz aqui?!!!! Pera você é uma raposa de pé?"}, {x=0.75, y=0.75}, true, {attack_frame=23, value=0.05})
end

function npcs:updateFrame(i, dt)
  if self.on_the_screen[i].animation~='' then
    self.on_the_screen[i].acc= self.on_the_screen[i].acc+(dt * math.random(1, 5))
    if self.on_the_screen[i].acc>=(0.5) then
      self.on_the_screen[i].frame= self.on_the_screen[i].frame + 1
      self.on_the_screen[i].acc= 0

      -- A primeira estrutura condicional serve para recomeçar uma animação, após f ele recomeça a animação no frame i
      -- hold_animation é uma propriedade que serve para travar de um frame a outro até a animação anterior chegar ao seu f
      if self.on_the_screen[i].hold_animation==false then
        if
          (self.on_the_screen[i].frame<self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].i or
          self.on_the_screen[i].frame>self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].f)
        then
          self.on_the_screen[i].frame= self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].i
        end
      end

      --- Se a animação não é travada significa que ela está iniciando uma nova animação, essa estrutura basicamente a função de travar animação se ela está no primeiro frame, e quando ele chegar no último ela será destravada
      if self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].until_finished==true then
        self.on_the_screen[i].previous_animation= self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation]
        self.on_the_screen[i].hold_animation= (self.on_the_screen[i].frame<self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].f-1 and self.on_the_screen[i].frame>=self.on_the_screen[i].frame_positions[self.on_the_screen[i].animation].i)
      elseif self.on_the_screen[i].previous_animation.until_finished==true and self.on_the_screen[i].hold_animation==true then
        self.on_the_screen[i].hold_animation= (self.on_the_screen[i].frame<self.on_the_screen[i].previous_animation.f-1 and self.on_the_screen[i].frame>=self.on_the_screen[i].previous_animation.i)
      end

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
        self:updateFrame(i, dt)
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