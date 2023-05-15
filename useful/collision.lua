local Collision= { teste= true }

function Collision:circle(pi, pf, r)
  return math.sqrt(
    ((pf.x-pi.x)^2)+
    ((pf.y-pi.y)^2)
  )<=r
end

function Collision:ellipse(pi, pf, a, b, r)
  return math.sqrt(
    (((pf.x-pi.x-_G.map.cam.p.x)^2)/(a^2))+
    (((pf.y-pi.y)^2)/(b^2))
  )<=r
end

function Collision:quad(obj_one, obj_two, cam)
  local left= obj_one.p.x+(obj_one.body.w/2)>obj_two.p.x-(obj_two.body.w/2)+cam.p.x
  local right= obj_one.p.x-(obj_one.body.w/2)<obj_two.p.x+(obj_two.body.w/2)+cam.p.x
  local top= obj_one.p.y-(obj_one.body.h/2)<obj_two.p.y-(obj_two.body.h/2)
  local bottom= obj_one.p.y+(obj_one.body.h/2)>obj_two.p.y+(obj_two.body.h/2)
  return (left and right) and (top and bottom)
end

function Collision:quadDraw(obj, cam)
  local top= obj.p.y-(obj.body.h/2)
  local left= obj.p.x-(obj.body.w/2)
  local bottom= obj.p.y+(obj.body.h/2)
  local right= obj.p.x+(obj.body.w/2)

  if cam then
    left= left-cam.p.x
    right= right-cam.p.x
  end
  local vertices= {
    left, top,
    right, top,
    right, bottom,  
    left, bottom
  }
  love.graphics.setColor(150/255, 0, 0)
  love.graphics.polygon('line', vertices)
  love.graphics.setColor(1, 1, 1)
end


return Collision