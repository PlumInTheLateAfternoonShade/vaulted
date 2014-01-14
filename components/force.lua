local forceSystem = require('systems.forceSystem')

-- An effect that imparts a force on objects it encounters.
local force = {}

function force.create(id, h, v, x, y)
    local c = {}
    c.id = id
    c.h = h
    c.v = v
    c.x = x
    c.y = y
    forceSystem:add(c)
    return c
end

return force
