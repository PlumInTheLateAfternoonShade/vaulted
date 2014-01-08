local graphicsSystem = require('systems.graphicsSystem')

-- Allows an object in the game world with this component to be colored as a polygon.
local polygonRenderer = {}

function polygonRenderer.create(id, color)
    local c = {}
    c.id = id
    c.color = color
    graphicsSystem.addPolygon(c)
    return c
end

return polygonRenderer
