local tbl= {}

function tbl:deepCopy(original)
  local copy
  if type(original) == "table" then
      copy = {}
      for key, value in pairs(original) do
          copy[self:deepCopy(key)] = self:deepCopy(value)
      end
      setmetatable(copy, self:deepCopy(getmetatable(original)))
  else
      copy = original
  end
  return copy
end

return tbl