local CameraManager= {
    p= {
        x= 900, y= 0
    }
}

function CameraManager:getPosition()
    return self.p
end

return CameraManager