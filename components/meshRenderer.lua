local graphicsSystem = require('systems.graphicsSystem')

local Point = require 'geometry.Point'

-- Allows an object in the game world with this component to be colored as a mesh.
local meshRenderer = {}

function meshRenderer.create(id, color, imageName)
    local c = {}
    c.id = id
    c.color = color
    c.imageName = imageName
    c.needsInit = true
    graphicsSystem:addMesh(c)
    return c
end

return meshRenderer
