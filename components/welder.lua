local jointSystem = require('systems.jointSystem')
-- Allows two physics components to be welded together at a point.
local welder = {}

function welder.prototype(id1, id2, point, shouldCollide)
    local c = 
    {
        name = 'welder',
        id1 = id1,
        id2 = id2,
        point = point,
        shouldCollide = shouldCollide or false,
    }
    function c:addToSystems(id)
        self.id = id
        jointSystem:add(self)
    end
    return c
end

function welder.create(id, ...)
    local c = welder.prototype(...)
    c:addToSystems(id)
    return c
end

return welder
