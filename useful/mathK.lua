local mathK= {}

function mathK:around(number, n_decimal_values)
  if type(number)=='number' then
    local str_number= tostring(number)
    if type(str_number:find('%.'))~='nil' then
      local starting_position_of_decimal_value= str_number:find('%.')+1
      for i=str_number:len(), starting_position_of_decimal_value, -1 do
        if i<=str_number:len() then
          local sub_str_number= str_number:sub(i,i)
          if sub_str_number~='e' and sub_str_number~='-' and sub_str_number~='' and sub_str_number~='.' and tonumber(sub_str_number)>4 then
            starting_position_of_decimal_value= str_number:find('%.')+1
            local str_number_before= str_number:sub(1,i-1)
            local str_number_after= str_number:sub(i+1, str_number:len())
            str_number= str_number_before..'0'..str_number_after
            str_number= tostring(tonumber(str_number)+(math.pow(10 ,(-i+starting_position_of_decimal_value))))
          end
        end
      end
      local n_decimal_values_max= str_number:sub(starting_position_of_decimal_value, str_number:len()):len()
      local final_str_number= str_number:sub(1,starting_position_of_decimal_value-2-(n_decimal_values==nil and 0 or (n_decimal_values<n_decimal_values_max and n_decimal_values or n_decimal_values_max)))
      local final_number= tonumber(final_str_number)
      return final_number
    else
      return number
    end
  end
end

function mathK:sqrt(number, exponent)
  return number*(1/exponent)
end

return mathK