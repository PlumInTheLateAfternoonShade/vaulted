local walkingSystem = require('systems.walkingSystem')

-- Allows an object in the game world with this component to have a dynamic walker.
local walker = {}

function walker.create(id, force)
    local c = {}
    c.id = id
    c.force = force
    c.facing = 1
    c.direction = 0
    walkingSystem:add(c)
    return c
end

return walker
