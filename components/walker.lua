local walkingSystem = require('systems.walkingSystem')

-- Allows an object in the game world with this component to have a dynamic walker.
local walker = {}

function walker.prototype(force, targetVeloc)
    local c = 
    {
        name = "walker",
        force = force,
        targetVeloc = targetVeloc,
        facing = 1,
        direction = 0,
    }
    function c:addToSystems(id)
        self.id = id
        walkingSystem:add(self)
    end
    return c
end
function walker.create(id, ...)
    local c = walker.prototype(...)
    c:addToSystems(id)
    return c
end

return walker
