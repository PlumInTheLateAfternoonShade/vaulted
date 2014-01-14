local graphicsSystem = require('systems.graphicsSystem')

local Point = require 'geometry.Point'

-- Allows an object in the game world with this component to be colored as a mesh.
local meshRenderer = {}

function meshRenderer.prototype(color, imageName)
    local c = {}
    c.color = color
    c.imageName = imageName
    c.needsInit = true
    function c:addToSystems(id)
        self.id = id
        graphicsSystem:addMesh(self)
    end
    return c
end

function meshRenderer.create(id, color, imageName)
    local c = meshRenderer.prototype(color, imageName)
    c:addToSystems(id)
    return c
end

return meshRenderer
