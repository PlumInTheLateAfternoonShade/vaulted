local positionSystem = require('systems.positionSystem')

-- Allows an object in the game world with this component to have a dynamic position.
local position = {}

function position.prototype(coords, center)
    local c = { name = 'position' }
    c.center = center
    c.coords = coords
    function c:addToSystems(id)
        self.id = id
        positionSystem:addAndTranslateToCoords(self)
    end
    return c
end

function position.create(id, coords, center)
    local c = position.prototype(coords, center)
    c:addToSystems(id)
    return c
end

return position
