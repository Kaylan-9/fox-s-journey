local Object= require('object.object')
local CameraManager= require('manager.cameraManager')
local metatable= {
  __call= function(self, owner)
    local body= {
      w= 50,
      h= 50
    }
    local initial_position= {
      x= (owner.scale_factor.x==math.abs(owner.scale_factor.x) and
        (body.w/2)+owner.p.x+(owner.body.w/2)+1 or
        (body.w/2)-owner.p.x-(owner.body.w/2)-1
      ),
      y= (owner.p.y)
    }
    if owner.name=='player' then
      initial_position.x= initial_position.x+(owner.cam.x*0.5)
      initial_position.y= initial_position.y+(owner.cam.y*0.25)
    end
    local fireball= Object(
      owner.objectManager,
      {
        name= 'fireball',
        right_edge_image= 1,
        scale_factor= {
          x= (owner.scale_factor.x/owner.scale_factor.x)*5,
          y= 5
        },
      },
      body,
      initial_position,
      CameraManager:getPosition(),
      {x= 0.5, y= 0.25},
      love.graphics.newImage('assets/graphics/fireball.png'),
      {
        energy_preservation= 0.44,
        mass= 3.5,
        fixed= false,
        objects= owner.objectManager:getList({'player'})
      },
      {
        walking_speed= {min= 5, max= 7},
      }
    )
    setmetatable(fireball, {__index= self})
    return fireball
  end
}
local Fireball= {}

setmetatable(Fireball, metatable)

return Fireball