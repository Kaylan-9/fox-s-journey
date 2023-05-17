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
    obj.i=1
    obj.lines= {}
    obj.lines_n= 0
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

function Balloon:setTiles_n()
  self.tiles_n.x= math.floor((_G.screen.w>self.max_width and self.max_width or _G.screen.w)/(self.tile.size.w*self.s.x))
  self.spacing.w= (_G.screen.w-(self.tiles_n.x*self.tile.size.w))/2
  self.width_msg= (self.tiles_n.x*self.tile.size.w)
end

function Balloon:update()
  self:setTiles_n()
  self:quebra_linhas_msg()
end

function Balloon:calc_lines_n(text_w)
  return math.ceil(text_w*2/(self.width_msg-(self.text_spacing*2)))
end

function Balloon:quebra_linhas_msg()
  if #self.messages>0 then
    self.lines= {}
    local text_w= font:getWidth(self.messages[self.i])
    self.lines_n= self:calc_lines_n(text_w)
    local pi= 1
    local pf= 2
    local subtext= 'test'

    while #self.lines<self.lines_n-1 do
      if #self.lines>0 then pi= utf8.offset(self.messages[self.i], pf) end
      pf= pi + 1
      subtext= self.messages[self.i]:sub(pi, utf8.offset(self.messages[self.i], pf)-1)
      while font:getWidth(subtext)<(self.width_msg/2)-(self.text_spacing*2) do
        pf= pf + 1
        subtext= self.messages[self.i]:sub(pi, utf8.offset(self.messages[self.i], pf)-1)
      end
      self.lines[#self.lines+1]= subtext
    end
    if #self.lines>1 then pi= utf8.offset(self.messages[self.i], pf)
    else pi= utf8.offset(self.messages[self.i], pi)
    end
    subtext= self.messages[self.i]:sub(pi, utf8.offset(self.messages[self.i], utf8.len(self.messages[self.i])))
    self.lines[#self.lines+1]= subtext
  end
end

function Balloon:draw()
  if #self.messages>0 then
    self:desenha_forma()
    self:escreve_texto()
  end
end

function Balloon:desenha_forma()
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

function Balloon:escreve_texto()
  love.graphics.setColor(0/255, 0/255, 0/255, 255/255)
  if #self.lines==self.lines_n then
    for i=1, self.lines_n do
      love.graphics.print(self.lines[i], self.spacing.w+self.text_spacing, self.spacing.h+self.text_spacing+((i-1)*15*2), self.angle, 2, 2)
    end
  end
  love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end



return Balloon