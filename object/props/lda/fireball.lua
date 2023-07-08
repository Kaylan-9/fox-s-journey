local Object= require('object.object')
local CameraManager= require('manager.cameraManager')
local metatable= {
  __call= function(self, owner)
    local body= {
      w= 32,
      h= 32
    }
    local fireball= Object(
      {
        name= 'fireball',
        right_edge_image= 1,
        scale_factor= {
          x= (owner.scale_factor.x/owner.scale_factor.x)*2,
          y= 2
        },
      },
      body,
      {
        x= (owner.scale_factor.x==math.abs(owner.scale_factor.x) and
          (body.w/2)+owner.p.x+(owner.body.w/2) or
          (body.w/2)-owner.p.x-(owner.body.w/2)
        ),
        y= (owner.scale_factor.x==math.abs(owner.scale_factor.x) and
          (body.h/2)+owner.p.y+(owner.body.h/2) or
          (body.h/2)-owner.p.y-(owner.body.h/2)
        )
      },
      CameraManager:getPosition(),
      {x= 0.5, y= 0.5},
      love.graphics.newImage('assets/graphics/fireball.png'),
      {
        energy_preservation= 0.44,
        mass= 3.5,
        fixed= false,
        objects= owner.physics.objects
      },
      {
        walking_speed= {min= 20, max= 25},
      }
    )
    setmetatable(fireball, {__index= self})
    return fireball
  end
}
local Fireball= {}

setmetatable(Fireball, metatable)

return Fireball