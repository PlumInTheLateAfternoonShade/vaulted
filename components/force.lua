local forceSystem = require('systems.forceSystem')

-- An effect that imparts a force on objects it encounters.
local force = {}

function force.prototype(h, v, x, y)
    local c = {}
    c.name = 'force'
    c.h = h
    c.v = v
    c.x = x
    c.y = y
    function c:addToSystems(id)
        self.id = id
        forceSystem:add(self)
    end
    return c
end

function force.create(id, h, v, x, y)
    local c = force.prototype(h, v, x, y)
    c:addToSystems(id)
    return c
end

return force
