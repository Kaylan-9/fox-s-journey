local Items, metatable= {}, {
  __call= function(self)
    local object= {}
    object.list= {}
    setmetatable(object, {__index= self})
    return object
  end
}

function Items:removeItem(indice)
  table.remove(self.list, indice)
end

return Items