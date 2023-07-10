local Timer= {}

function Timer:new(timer)
  return {
    duration= timer.duration,
    can_repeat= (timer.can_repeat==nil and false or timer.can_repeat),
    t_i= 0,
    t_f= 0,
    parent= timer.parent,
    func= timer[1],
    setTimeOut= function(self, timer)
      self:start(timer)
      self:finish()
    end,
    start= function(self, timer)
      if timer~=nil then 
        if not self.parent then self.parent= timer.parent end
        if not self.func then self.func= timer[1] end
      end
      if self.t_i==0 then self.t_i= love.timer.getTime() end
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
          if self.can_repeat then self:reset() end
        end
        return time_passed
      end
      return false
    end
  }
end

return Timer