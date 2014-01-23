local positionSystem = require('systems.positionSystem')

-- Allows an object in the game world with this component to have a dynamic position.
local position = {}

function position.prototype(coords, center, shapeName, radius)
    local c = 
    {
        name = 'position',
        center = center,
        coords = coords,
        shapeName = shapeName or 'polygon',
        radius = radius,
        shouldPreview = true,
    }
    function c:addToSystems(id)
        self.id = id
        positionSystem:addAndTranslateToCoords(self)
    end
    return c
end

function position.create(id, ...)
    local c = position.prototype(...)
    c:addToSystems(id)
    return c
end

return position
