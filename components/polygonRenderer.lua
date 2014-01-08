require 'lib.deepcopy.deepcopy'
local Point = require 'geometry.Point'

-- Allows an object in the game world with this component to be colored as a polygon.
local polygonRenderer = {}

function polygonRenderer.create(id, color)
    local c = {}
    c.id = id
    c.color = color
    return c
end

return polygonRenderer
