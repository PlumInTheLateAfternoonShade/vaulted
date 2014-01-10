local positionSystem = require('systems.positionSystem')

-- Allows an object in the game world with this component to have a dynamic position.
local position = {}

function position.create(id, coords, center)
    local c = {}
    c.id = id
    c.center = center
    c.coords = coords
    positionSystem:addAndTranslateToCoords(c)
    return c
end

return position
