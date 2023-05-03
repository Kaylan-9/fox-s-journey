local Tileset= {}
local metatable = {
  __call = function(self, name, n, adjustment)
    local object= {}
    object.name= name
    object.obj= love.graphics.newImage(object.name)
    object.n= n
    object.tiles= {}
    object.size= {
      w=object.obj:getWidth(),
      h=object.obj:getHeight()
    }
    object.adjustment= {w=0, h=0}
    if adjustment~=nil then object.adjustment= adjustment end
    object.tileSize= {
      w= (object.size.w/object.n.x)+object.adjustment.w,
      h= (object.size.h/object.n.y)+object.adjustment.h
    }
    setmetatable(object, {__index= self})
    object:seTile()
    return object 
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