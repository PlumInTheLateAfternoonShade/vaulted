local graphicsSystem = require('systems.graphicsSystem')

-- Allows an object in the game world with this component to be colored as a shape.
local shapeRenderer = {}

function shapeRenderer.create(id, color)
    local c = {}
    c.id = id
    c.color = color
    c.shouldPreview = true
    graphicsSystem:addShape(c)
    return c
end

return shapeRenderer
