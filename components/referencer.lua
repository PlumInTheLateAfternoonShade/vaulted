local referencerSystem = require('systems.referenceSystem')

-- An effect that imparts a referencer on objects it encounters.
local referencer = {}

function referencer.prototype(parentId)
    local c = {}
    c.name = 'referencer'
    c.parentId = parentId
    function c:addToSystems(id)
        self.id = id
        referencerSystem:add(self)
    end
    return c
end

function referencer.create(id, ...)
    local c = referencer.prototype(...)
    c:addToSystems(id)
    return c
end

return referencer
