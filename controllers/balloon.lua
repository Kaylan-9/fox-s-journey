local font= love.graphics.getFont()
local utf8= require('utf8')
local Balloon, metatable= {}, {
  __call= function(self)
    local obj= {}
    obj.angle= 0
    obj.s= {}
    obj.s.x= 1
    obj.s.y= 1
    obj.messages= {}
    obj.indice=1
    obj.p_character= {
      i= 1, 
      f= 2
    }
    obj.lines= {}
    obj.lines_n= 0
    obj.subtext= ''
    setmetatable(obj, {__index= self})
    obj:load()
    return obj
  end
}

setmetatable(Balloon, metatable)

function Balloon:load()
  self.img= {}
  self.img.obj= love.graphics.newImage("assets/graphics/Comic/comic-10.png")
  self.img.size= {
    w= self.img.obj:getWidth(),
    h= self.img.obj:getHeight()
  }
  self.tiles_n= {}
  self.tile= {}
  self.objs= {
    edge= love.graphics.newQuad(25, 155, 80, 80, self.img.size.w, self.img.size.h),
    corner=  love.graphics.newQuad(25, 254, 80, 80, self.img.size.w, self.img.size.h)
  }
  self.max_width= 1280
  self.spacing= {
    w=0,
    h=30
  }
  self.text_spacing= 30
  self.tile.size= {
    w= 80,
    h= 80
  }
end

function Balloon:setTilesN()
  self.tiles_n.x= math.floor((_G.screen.w>self.max_width and self.max_width or _G.screen.w)/(self.tile.size.w*self.s.x))
  self.spacing.w= (_G.screen.w-(self.tiles_n.x*self.tile.size.w))/2
  self.width_msg= (self.tiles_n.x*self.tile.size.w)
end

function Balloon:update()
  self:setTilesN()
  self:quebraLinhasMsg()
end

function Balloon:calcLinesN(text_w)
  return math.ceil(text_w*2/(self.width_msg-(self.text_spacing*2)))
end

function Balloon:quebraLinhasMsg()
  -- mensagem atual -> math.ceil(self.indice) 

  if #self.messages>0 then
    local text_w= font:getWidth(self.messages[math.ceil(self.indice)])
    self.lines_n= self:calcLinesN(text_w)
    self.lines= {}
    self.p_character.i, self.p_character.f= 1, 1
    

    while #self.lines<self.lines_n do
      -- pega a última posição do character e coloca como posição inicial da próxima linha
      if #self.lines>0 then 
        self.p_character.i= utf8.offset(self.messages[math.ceil(self.indice)], self.p_character.f)
      end
      -- aumenta o indice final da posição do texto até a posição do character final do trecho de texto 
      self.p_character.f= self.p_character.i
      self.subtext= self.messages[math.ceil(self.indice)]:sub(self.p_character.i, utf8.offset(self.messages[math.ceil(self.indice)], self.p_character.f))
      self:letraPorLetra()
      self.lines[#self.lines+1]= self.subtext
    end
  end
end

function Balloon:letraPorLetra()
  -- Se é a última linha
  if #self.lines==self.lines_n-1 then
    if #self.lines>1 then self.p_character.i= self.p_character.f end
    self.subtext= self.messages[math.ceil(self.indice)]:sub(self.p_character.i, self.messages[math.ceil(self.indice)]:len())    
    return
  end

  local comprimento_subtext= font:getWidth(self.subtext)
  while comprimento_subtext<(self.width_msg/2)-(self.text_spacing*2) do
    self.p_character.f= self.p_character.f + 1
    self.subtext= self.messages[math.ceil(self.indice)]:sub(self.p_character.i, utf8.offset(self.messages[math.ceil(self.indice)], self.p_character.f)-1)
    comprimento_subtext= font:getWidth(self.subtext)
  end
end 

function Balloon:draw()
  if #self.messages>0 then
    self:desenhaForma()
    self:escreveTexto()
  end
end

function Balloon:desenhaForma()
  for i=1, self.tiles_n.x do
    for j=1, 3 do
      if (i==1 and j==1) then
        love.graphics.draw(self.img.obj, self.objs.edge, self.spacing.w+((i-1)*self.tile.size.w*self.s.x), self.spacing.h+((j-1)*self.tile.size.h*self.s.y), self.angle, self.s.x, self.s.y)
      elseif (i==1 and j==3) then
        love.graphics.draw(self.img.obj, self.objs.edge, self.spacing.w+((i-1)*self.tile.size.w*self.s.x), self.spacing.h+((j)*self.tile.size.h*self.s.y), self.angle, self.s.x, -math.abs(self.s.y))
      elseif (i==self.tiles_n.x and j==1) then
        love.graphics.draw(self.img.obj, self.objs.edge, self.spacing.w+((i)*self.tile.size.w*self.s.x), self.spacing.h+((j-1)*self.tile.size.h*self.s.y), self.angle, -math.abs(self.s.x), self.s.y)
      elseif (i==self.tiles_n.x and j==3) then
        love.graphics.draw(self.img.obj, self.objs.edge, self.spacing.w+((i)*self.tile.size.w*self.s.x), self.spacing.h+((j)*self.tile.size.h*self.s.y), self.angle, -math.abs(self.s.x), -math.abs(self.s.y))
      elseif (j==1) then
        love.graphics.draw(self.img.obj, self.objs.corner, self.spacing.w+((i-1)*self.tile.size.w*self.s.x), self.spacing.h+((j-1)*self.tile.size.h*self.s.y), math.rad(90), self.s.x, self.s.y, 0, self.tile.size.h)
      elseif (j==3) then
        love.graphics.draw(self.img.obj, self.objs.corner, self.spacing.w+((i-1)*self.tile.size.w*self.s.x), self.spacing.h+((j)*self.tile.size.h*self.s.y), math.rad(270), self.s.x, self.s.y)
      elseif (i==1) then
        love.graphics.draw(self.img.obj, self.objs.corner, self.spacing.w+((i-1)*self.tile.size.w*self.s.x), self.spacing.h+((j-1)*self.tile.size.h*self.s.y), self.angle, self.s.x, self.s.y)
      elseif (i==self.tiles_n.x) then
        love.graphics.draw(self.img.obj, self.objs.corner, self.spacing.w+((i-1)*self.tile.size.w*self.s.x), self.spacing.h+((j-1)*self.tile.size.h*self.s.y), self.angle, -math.abs(self.s.x), self.s.y, self.tile.size.w, 0)
      elseif ((i>1 and i<self.tiles_n.x) and (j>1 and j<3)) then
        love.graphics.rectangle("fill", self.spacing.w+((i-1)*self.tile.size.w*self.s.x), self.spacing.h+((j-1)*self.tile.size.h*self.s.y), self.tile.size.w*self.s.x, self.tile.size.h*self.s.y)
      end
    end
  end
end

function Balloon:escreveTexto()
  love.graphics.setColor(0/255, 0/255, 0/255, 255/255)
  if #self.lines==self.lines_n then
    for i=1, self.lines_n do
      love.graphics.print(self.lines[i], self.spacing.w+self.text_spacing, self.spacing.h+self.text_spacing+((i-1)*15*2), self.angle, 2, 2)
    end
  end
  love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end



return Balloon