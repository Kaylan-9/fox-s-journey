local Tileset= {}
local metatable = {
  __call = function(self, name_img, n)
    local tileset= {}
    tileset.name_img= name_img
    tileset.img= love.graphics.newImage(tileset.name_img)
    tileset.n= n
    tileset.tiles= {}
    tileset.size= {w=tileset.img:getWidth(), h=tileset.img:getHeight()}
    tileset.tileSize= {w= (tileset.size.w/tileset.n.x), h= (tileset.size.h/tileset.n.y)}
    setmetatable(tileset, {__index= self})
    tileset:seTile()
    return tileset
  end
}

setmetatable(Tileset, metatable)

function Tileset:seTile()
  for i=1, self.n.x do
    for j=1, self.n.y do
      self.tiles[i+((j-1)*self.n.x)]= love.graphics.newQuad(
        (i-1)*self.tileSize.w, 
        (j-1)*self.tileSize.h,
        self.tileSize.w,
        self.tileSize.h,
        self.size.w,
        self.size.h
      )
    end
  end
end

return Tileset
