local Point = require 'geometry.Point'
local bodySystem = require 'systems.bodySystem'

-- Allows an object in the game world with this component to be collided with.
local body = {}

function body.prototype(type, breakable, initV)
    local c = { name = 'body' }
    c.firstUpdate = true
    c.type = type
    c.breakable = breakable or false
    c.initV = initV or Point(0, 0)
    c.maxMassToBreak = 40
    function c:addToSystems(id)
        self.id = id
        bodySystem:add(self)
    end
    return c
end

function body.create(id, ...)
    local c = body.prototype(...)
    c:addToSystems(id)
    return c
end

return body
