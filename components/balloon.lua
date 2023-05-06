local font= love.graphics.getFont()
local utf8= require('utf8')
local lines= {}
local lines_n

local balloon= {
  angle= 0,
  s= {
    x= 1,
    y= 1
  },
  messages= {},
  i= 1
}

function balloon:load()
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

function balloon:setTiles_n()
  self.tiles_n.x= math.floor((_G.screen.w>self.max_width and self.max_width or _G.screen.w)/(self.tile.size.w*self.s.x))
  self.spacing.w= (_G.screen.w-(self.tiles_n.x*self.tile.size.w))/2
  self.size= (self.tiles_n.x*self.tile.size.w)
end

function balloon:update()
  self:setTiles_n()
  if #self.messages>0 then
    lines= {}
    local text_w= font:getWidth(self.messages[self.i])
    lines_n= math.ceil(text_w*2/(self.size-(self.text_spacing*2)))
    local pi= 1
    local pf= 2
    local subtext= 'test'

    while #lines<lines_n-1 do
      if #lines>0 then pi= utf8.offset(self.messages[self.i], pf) end
      pf= pi + 1
      subtext= self.messages[self.i]:sub(pi, utf8.offset(self.messages[self.i], pf)-1)
      while font:getWidth(subtext)<(self.size/2)-(self.text_spacing*2) do
        pf= pf + 1
        subtext= self.messages[self.i]:sub(pi, utf8.offset(self.messages[self.i], pf)-1)
      end
      lines[#lines+1]= subtext
    end
    pi= utf8.offset(self.messages[self.i], pf)
    subtext= self.messages[self.i]:sub(pi, utf8.offset(self.messages[self.i], utf8.len(self.messages[self.i])))
    lines[#lines+1]= subtext
  end
end

function balloon:draw()
  if #self.messages>0 then
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
    love.graphics.setColor(0/255, 0/255, 0/255, 255/255)
    if #lines==lines_n then
      for i=1, lines_n do
        love.graphics.print(lines[i], self.spacing.w+self.text_spacing, self.spacing.h+self.text_spacing+((i-1)*15*2), self.angle, 2, 2)
      end
    end
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
  end
end

return balloon