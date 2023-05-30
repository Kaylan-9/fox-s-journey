local font= love.graphics.getFont()
local Menu= {
  mouse= {},
  button_list= {},
  button_default= {
    audio= love.audio.newSource('assets/audios/click.mp3', 'static'),
    size= {x= 2, y= 2},
    extra_size= {x= 0, y= 0},
    extra_size_max= {x= 1.5, y= 1.5},
    distancia= {x= 50, y= 50},
  }
}

function Menu:lastButton()
  return self.button_list[#self.button_list]
end

function Menu:load()
  self:loadMouse()
  self:loadButtons()
end 

function Menu:loadMouse()
  self.mouse.p= {x= 0, y= 0}
  self.mouse.down= false
end

function Menu:buttonSair()
  love.event.quit()
end

function Menu:buttonComecar()
  if self.escrito=='começar' then
    self.escrito='voltar'
    self.body.w= font:getWidth(self.escrito)
  end
  _G.game.pause= false
end

function Menu:loadButtons()
  self:newButton('começar', self.buttonComecar, {x= _G.screen.w/2, y= _G.screen.h/2}, nil, true)
  self:newButtonAbaixoDoAnterior('reiniciar', self.resetGame, false, self.enableResetButton)
  self:newButtonAbaixoDoAnterior('sair', self.buttonSair, true)
end

function Menu:resetGame()
  _G.game.pause= false
  _G.game.game_stage= 0
end

function Menu:enableResetButton()
  if _G.game.game_stage>0 then
    self.active= true
  else 
    self.active= false
  end
end

function Menu:newButtonAbaixoDoAnterior(escrito, func, active, activateButton)
  local last_button= self:lastButton()
  local p= {
    x= last_button.p.x,
    y= last_button.p.y+last_button.body.h+self.button_default.distancia.y
  }
  self:newButton(escrito, func, p, nil, active, activateButton)
end

function Menu:newButton(escrito, func, p, size, active, activateButton)
  local new_button= {
    escrito= escrito,
    p= p,
    active= active,
    body= {
      w= font:getWidth(escrito),
      h= font:getHeight(),
    },
    extra_size= _G.tbl:deepCopy(self.button_default.extra_size),
    draw= self.drawButton,
    activateButton= activateButton or false,
    clickingMouse= self:mouseClickOnTheButton(func)
  }

  if size then new_button.size= size
  else new_button.size= self.button_default.size
  end

  table.insert(self.button_list, new_button)
end

function Menu:mouseClickOnTheButton(func)
  return function(self, mouse)
    if self.active then
      local left = self.p.x-((self.body.w/2)*self.size.x)
      local right= self.p.x+((self.body.w/2)*self.size.x)
      local top= self.p.y-((self.body.h/2)*self.size.y)
      local bottom= self.p.y+((self.body.h/2)*self.size.y)
      if mouse.p.x>left and mouse.p.x<right and mouse.p.y>top and mouse.p.y<bottom then
        local p_relacao_botao= {
          x= math.abs(self.p.x-mouse.p.x),
          y= math.abs(self.p.y-mouse.p.y)
        }
        self.extra_size.x= (1-(p_relacao_botao.x/((self.body.w/2)*self.size.x)))*Menu.button_default.extra_size_max.x
        self.extra_size.y= (1-(p_relacao_botao.y/((self.body.h/2)*self.size.y)))*Menu.button_default.extra_size_max.y
        
        if mouse.down then
          Menu:playMouseClickSound()
          func(self)
        end
      else
        self.extra_size= _G.tbl:deepCopy(Menu.button_default.extra_size)
      end
    end
  end
end

function Menu:playMouseClickSound()
  self.button_default.audio:setVolume(3)
  self.button_default.audio:play()
end

function Menu:updateMouse()
  self.mouse.p= {x=love.mouse.getX(), y=love.mouse.getY()}
  self.mouse.down= love.mouse.isDown(1)
end

function Menu:updateButtons()
  for i=1, #self.button_list do 
    self.button_list[i]:clickingMouse(self.mouse)
    if self.button_list[i].activateButton then
      self.button_list[i]:activateButton()
    end
  end
end

function Menu:update()
  self:updateMouse()
  self:updateButtons()
end

function Menu:drawButton()
  if self.active then
    love.graphics.print(
      self.escrito, 
      self.p.x, self.p.y, 
      0, 
      self.size.x+self.extra_size.x, self.size.y+self.extra_size.y, 
      self.body.w/2, self.body.h/2
    )
  end
end

function Menu:drawButtons()
  for i=1, #self.button_list do 
    self.button_list[i]:draw()
  end
end

function Menu:draw()
  self:drawButtons()
end

return Menu