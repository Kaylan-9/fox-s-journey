local Timer= {}

function Timer:new(duracao)
  return {
    duracao= duracao,
    t_i= 0,
    t_f= 0,
    start=function(self)
      if self.t_i==0 then
        self.t_i= love.timer.getTime()
      end 
    end,
    reset=function(self)
      self.t_i= 0
      self.t_f= 0
    end,
    finish=function(self)
      self.t_f= love.timer.getTime()
      local perocrrido=  self.t_f - self.t_i
      return perocrrido>=self.duracao
    end
  }
end

return Timer