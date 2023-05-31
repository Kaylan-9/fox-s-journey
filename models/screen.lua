local font= love.graphics.getFont()
local button_default= {
  audio= love.audio.newSource('assets/audios/click.mp3', 'static'),
  size= {x= 2, y= 2},
  extra_size= {x= 0, y= 0},
  extra_size_max= {x= 1.5, y= 1.5},
  distancia= {x= 50, y= 50},
}

local metatable, Screen= {
  __call =function(self)
    local obj= {}
    obj.mouse= {}
    obj.obj_list= {}
    setmetatable(obj, {__index= self})
    return obj 
  end
}, {}

setmetatable(Screen, metatable)

function Screen:lastObject()
  return self.obj_list[#self.obj_list]
end

function Screen:load()
  self:loadMouse()
  self:loadButtons()
end 

function Screen:loadMouse()
  self.mouse.p= {x= 0, y= 0}
  self.mouse.down= false
end

function Screen:newWritingAbaixoDoAnterior(escrito, size, active, activateObject)
  local last_object= self:lastObject()
  local p= {
    x= last_object.p.x,
    y= last_object.p.y+last_object.body.h+button_default.distancia.y
  }
  self:newWriting(escrito, p, size, active, activateObject)
end

function Screen:newButtonAbaixoDoAnterior(escrito, func, active, activateObject)
  local last_object= self:lastObject()
  local p= {
    x= last_object.p.x,
    y= last_object.p.y+last_object.body.h+button_default.distancia.y
  }
  self:newButton(escrito, func, p, nil, active, activateObject)
end

function Screen:newButton(escrito, func, p, size, active, activateObject)
  local new_button= self:newGenericObject(escrito, p, size, active, activateObject)
  new_button.extra_size= _G.tbl:deepCopy(button_default.extra_size)
  new_button.clickingMouse= self:mouseClickOnTheButton(func)
  table.insert(self.obj_list, new_button)
end

function Screen:newGenericObject(escrito, p, size, active, activateObject)
  local new_object= {
    escrito= escrito,
    p= p,
    active= active,
    body= {
      w= font:getWidth(escrito),
      h= font:getHeight(),
    },
    draw= self.drawObject,
    activateObject= activateObject or false,
    size= size and size or button_default.size
  }
  return new_object
end
 
function Screen:newWriting(escrito, p, size, active, activateObject)
  local new_writing= self:newGenericObject(escrito, p, size, active, activateObject)
  table.insert(self.obj_list, new_writing)
end


function Screen:mouseClickOnTheButton(func)
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
        self.extra_size.x= (1-(p_relacao_botao.x/((self.body.w/2)*self.size.x)))*button_default.extra_size_max.x
        self.extra_size.y= (1-(p_relacao_botao.y/((self.body.h/2)*self.size.y)))*button_default.extra_size_max.y
        
        if mouse.down then
          Screen:playMouseClickSound()
          func(self)
        end
      else
        self.extra_size= _G.tbl:deepCopy(button_default.extra_size)
      end
    end
  end
end

function Screen:playMouseClickSound()
  button_default.audio:setVolume(3)
  button_default.audio:play()
end

function Screen:updateMouse()
  self.mouse.p= {x=love.mouse.getX(), y=love.mouse.getY()}
  self.mouse.down= love.mouse.isDown(1)
end

function Screen:updateButtons()
  for i=1, #self.obj_list do 
    if self.obj_list[i].clickingMouse then 
      self.obj_list[i]:clickingMouse(self.mouse)
    end
    if self.obj_list[i].activateObject then
      self.obj_list[i]:activateObject()
    end
  end
end

function Screen:update()
  self:updateMouse()
  self:updateButtons()
end

function Screen:drawObject()
  if self.active then
    love.graphics.print(
      self.escrito, 
      self.p.x, self.p.y, 
      0, 
      self.size.x+(self.extra_size and self.extra_size.x or 0), self.size.y+(self.extra_size and self.extra_size.y or 0), 
      self.body.w/2, self.body.h/2
    )
  end
end

function Screen:drawButtons()
  for i=1, #self.obj_list do 
    self.obj_list[i]:draw()
  end
end

function Screen:draw()
  self:drawButtons()
end

return Screen