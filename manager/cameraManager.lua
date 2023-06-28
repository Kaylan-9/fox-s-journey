local CameraManager= {
  p= {
    x= 0, y= 0
  }
}

function CameraManager:getPosition() return self.p end
function CameraManager:setPosition(prop, new_value) self.p[prop]= mathK:around(new_value) end

return CameraManager