local entitySystem = require('systems.entitySystem')
local collider = require('components.collider')
local polygonRenderer = require('components.polygonRenderer')
local position = require('components.position')
local physicsSystem = require('systems.physicsSystem')
local graphicsSystem = require('systems.graphicsSystem')
local positionSystem = require('systems.positionSystem')

-- Convenience functions to create objects in the entity component system.
local objectFactory = {}

function objectFactory.createTile(points, center)
    local id = entitySystem.register()
    local pos = position.create(id, points, center)
    positionSystem.addAndTranslateToCoords(pos)
    local col = collider.create(id, points, center, 0.5, 'static')
    physicsSystem.add(col)
    local rend = polygonRenderer.create(id, {r=math.random()*255, g=math.random()*255, b=math.random()*255})
    graphicsSystem.add(rend)
end

return objectFactory
