local healthSystem = require('systems.healthSystem')

-- Allows an object in the game world with this component to cast spells from a pool of health.
local health = {}

function health.create(id, inithealth, healthMult)
    local c = {}
    c.id = id
    c.health = inithealth or 0
    c.healthMult = healthMult or 1
    healthSystem:add(c)
    return c
end

return health
