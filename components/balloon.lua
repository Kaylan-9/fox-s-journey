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
  active= false,
  messages= {
    "Cheguei até aqui após inúmeros desafios, lutar contra inimigos poderosos e superar minhas próprias limitações. Mas agora, diante deste último obstáculo, sinto que minhas forças começam a falhar. Ainda assim, não posso desistir. Eu preciso encontrar uma maneira de superar esta fase e alcançar meu objetivo final. Lembrei-me das lições que aprendi ao longo do caminho: manter a calma em situações difíceis, não subestimar o poder da estratégia e, acima de tudo, confiar em minhas habilidades. Não posso deixar que o medo me paralise. Eu devo enfrentar este desafio de frente, com toda a coragem e determinação que possuo."
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
  self.text_spacing= 30
  self.tile.size= {
    w= 80,
    h= 80
  }
end

function balloon.setTiles_n(self)
  self.tiles_n.x= math.floor((_G.screen.w>self.max_width and self.max_width or _G.screen.w)/(self.tile.size.w*self.s.x))
  self.spacing.w= (_G.screen.w-(self.tiles_n.x*self.tile.size.w))/2
  self.size= (self.tiles_n.x*self.tile.size.w)
end

function balloon.update(self)
  self:setTiles_n()

  lines= {}
  local text_w= font:getWidth(self.messages[1])
  lines_n= math.ceil(text_w*2/(self.size-(self.text_spacing*2)))
  local pi= 1
  local pf= 2
  local subtext= 'test'

  while #lines<lines_n-1 do
    if #lines>0 then pi= utf8.offset(self.messages[1], pf) end
    pf= pi + 1
    subtext= self.messages[1]:sub(pi, utf8.offset(self.messages[1], pf)-1)
    while font:getWidth(subtext)<(self.size/2)-(self.text_spacing*2) do
      pf= pf + 1
      subtext= self.messages[1]:sub(pi, utf8.offset(self.messages[1], pf)-1)
    end
    lines[#lines+1]= subtext
  end
  pi= utf8.offset(self.messages[1], pf)
  subtext= self.messages[1]:sub(pi, utf8.offset(self.messages[1], utf8.len(self.messages[1])))
  lines[#lines+1]= subtext
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
  love.graphics.setColor(0/255, 0/255, 0/255, 255/255)

  if #lines==lines_n then
    for i=1, lines_n do
      love.graphics.print(lines[i], self.spacing.w+self.text_spacing, self.spacing.h+self.text_spacing+((i-1)*15*2), self.angle, 2, 2)
    end
  end
  
  love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

end

return balloon