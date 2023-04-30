local balloon= {
  p= {
    x= 0,
    y= 0
  },
  angle= 0,
  s= {
    x= 1,
    y= 1
  }
}

function balloon.load(self)
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
  self.tile.size= {
    w= 80,
    h= 80
  }
end

function balloon.setTiles_n(self)
  self.tiles_n.x= math.floor((_G.screen.w>self.max_width and self.max_width or _G.screen.w)/(self.tile.size.w*self.s.x))
  self.spacing.w= (_G.screen.w-(self.tiles_n.x*self.tile.size.w))/2
end

function balloon.update(self)
  self:setTiles_n()
end

function balloon.draw(self)
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

return balloon