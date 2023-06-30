local Timer= {}

function Timer:new(duration, loop, parent, func)
  return {
    duration= duration,
    loop= (loop==nil and false or loop),
    t_i= 0,
    t_f= 0,
    parent= parent,
    func= func,
    start= function(self, parent, func)
      self.parent= parent
      self.func= func
      if self.t_i==0 then
        self.t_i= love.timer.getTime()
      end
    end,
    reset= function(self)
      self.t_i= 0
      self.t_f= 0
    end,
    finish= function(self)
      if self.t_i~=0 then -- determinar que o timer foi iniciado
        self.t_f= love.timer.getTime()
        local elapsed_time= self.t_f - self.t_i -- tempo que passou
        local time_passed= elapsed_time>=self.duration -- timer terminou ou não?
        if time_passed then
          if self.parent and self.func then
            self.func(self.parent) -- executa função se ela é passada com parâmetro e o que inclui o pai dela para que ela apresente o comportamento desejável com objeto que é desejável ser executada
          end
          if self.loop then self:reset() end
        end
        return time_passed
      end
      return false
    end
  }
end

return Timer