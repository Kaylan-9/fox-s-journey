local Screen= require('models.screen')
local GameOver= Screen()

function GameOver:loadButtons()
  self:newWriting('Game Over', {x= _G.screen.w/2, y= _G.screen.h/2}, {x= 4, y= 4}, true, nil)
end 

return GameOver