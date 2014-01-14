local forceSystem = require('systems.forceSystem')

-- An effect that imparts a force on objects it encounters.
local force = {}

function force.prototype(id, h, v, x, y)
    local c = {}
    c.id = id
    c.h = h
    c.v = v
    c.x = x
    c.y = y
    function c:addToSystems()
        forceSystem:add(self)
    end
    return c
end

function force.create(id, h, v, x, y)
    local c = force.prototype(id, h, v, x, y)
    c:addToSystems()
    return c
end

return force
