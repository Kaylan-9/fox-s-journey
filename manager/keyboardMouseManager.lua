local keyboardMouseManager= {
    keys_used= {}
}

function keyboardMouseManager:markKeyUsed(name_behavior, keys, condition)
    self.keys_used[name_behavior]= (#keys==0 or love.keyboard.isDown(unpack(keys))) and (type(condition)=='nil' or condition)
end

function keyboardMouseManager:updateKeysUsed()
    self:markKeyUsed('left', {'a', 'left'})
    self:markKeyUsed('right', {'d', 'right'})
    self:markKeyUsed('jump', {'w', 'up'})
    self:markKeyUsed('run', {'space'}, self:getKeyUsed('right') or self:getKeyUsed('left'))
    self:markKeyUsed('move', {},  self:getKeyUsed('jump') or self:getKeyUsed('right') or self:getKeyUsed('left'))
    self:markKeyUsed('fireball', {'x'})
end

function keyboardMouseManager:update()
    self:updateKeysUsed()
end

function keyboardMouseManager:getKeyUsed(name_behavior)
    return self.keys_used[name_behavior]
end

return keyboardMouseManager
