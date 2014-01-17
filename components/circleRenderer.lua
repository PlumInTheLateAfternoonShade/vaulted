local graphicsSystem = require('systems.graphicsSystem')

-- Allows an object in the game world with this component to be colored as a circle.
local circleRenderer = {}

function circleRenderer.create(id, color, radius)
    local c = {}
    c.id = id
    c.color = color
    c.radius = radius
    c.shouldPreview = true
    graphicsSystem:addCircle(c)
    return c
end

return circleRenderer
