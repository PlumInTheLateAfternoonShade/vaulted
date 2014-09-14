local forceSystem = require('systems.forceSystem')

-- An effect that imparts a force on objects it encounters.
local force = {}

function force.prototype(h, v, x, y, casterId)
    local c = 
    {
        name = 'force',
        h = h,
        v = v,
        x = x,
        y = y,
        casterId = casterId,
        fired = false,
        shouldPreview = true,
    }
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
