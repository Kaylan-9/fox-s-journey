local Collision= { teste= true }

function Collision:circle(pi, pf, r)
  return math.sqrt(
    ((pf.x-pi.x)^2)+
    ((pf.y-pi.y)^2)
  )<=r
end

function Collision:ellipse(pi, pf, a, b, r)
  return math.sqrt(
    (((pf.x-pi.x)^2)/(a^2))+
    (((pf.y-pi.y)^2)/(b^2))
  )<=r
end


return Collision