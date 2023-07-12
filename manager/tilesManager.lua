local Tileset= require('obj.props.tileset')
local TilesManager= {
  tilesets= {}
}

function TilesManager:add(name, name_img, n)
  self.tilesets[name]= Tileset(name_img, n)
end

function TilesManager:load()
  self:add('map', 'assets/graphics/cave_tileset.png', {x=10, y=7})
  self:add('player', 'assets/graphics/player.png', {x=16, y=15})
  self:add('bat', 'assets/graphics/bat.png', {x=6, y=1})
end

function TilesManager:get(name)
  return self.tilesets[name]
end

return TilesManager