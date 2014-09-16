local lifetimeSystem = require('systems.lifetimeSystem')

-- Allows an object in the game world with this component to cast spells from a pool of lifetime.
local lifetime = {}

function lifetime.create(id, lifetime)
    local c = {}
    c.id = id
    c.lifetime = lifetime
    c.timeAlive = 0
    lifetimeSystem:add(c)
    return c
end

return lifetime
