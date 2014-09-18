-- An effect that imparts a force on objects it encounters.
local Force = require 'lib.middleclass'('Force',
                 require 'components.Component')
Force.static.systems = { require('systems.forceSystem'), nonserializable = true }

function Force:initialize(h, v, x, y, casterId)
    self.name = 'force' --TODO delete
    self.h = h
    self.v = v
    self.x = x
    self.y = y
    self.casterId = casterId
    self.fired = false
    self.shouldPreview = true
    self.systems = self.class.static.systems
end

function Force.create(id, ...)
    local c = Force:new(...)
    c:addToSystems(id)
    return c
end

return Force
