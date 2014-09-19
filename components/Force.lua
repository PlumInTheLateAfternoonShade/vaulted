-- An effect that imparts a force on objects it encounters.
local Force = require 'lib.middleclass'('Force',
                 require 'components.Component')

function Force:initialize(h, v, x, y, casterId)
    self.name = 'force' --TODO delete
    self.h = h
    self.v = v
    self.x = x
    self.y = y
    self.casterId = casterId
    self.fired = false
    self.shouldPreview = true
end

return Force
