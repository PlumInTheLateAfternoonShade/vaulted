local forceSystem = require('systems.forceSystem')

-- An effect that imparts a force on objects it encounters.
local force = {}

function force.prototype(h, v, x, y, casterId)
    local c = {}
    c.name = 'force'
    c.h = h
    c.v = v
    c.x = x
    c.y = y
    c.casterId = casterId
    function c:addToSystems(id)
        self.id = id
        forceSystem:add(self)
    end
    return c
end

function force.create(id, h, v, x, y, casterId)
    local c = force.prototype(h, v, x, y, casterId)
    c:addToSystems(id)
    return c
end

return force
