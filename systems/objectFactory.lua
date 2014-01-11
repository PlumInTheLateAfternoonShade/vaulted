local entitySystem = require('systems.entitySystem')
local collider = require('components.collider')
local polygonRenderer = require('components.polygonRenderer')
local meshRenderer = require('components.meshRenderer')
local position = require('components.position')
local element = require('components.element')

-- Convenience functions to create objects in the entity component system.
local objectFactory = {}

function objectFactory.init(world, cam)
    entitySystem:init(world, cam, objectFactory)
end

function objectFactory.createTile(points, center)
    local id = entitySystem.register()
    position.create(id, points, center)
    collider.create(id, points, center, 0.5, 'static')
    polygonRenderer.create(id, {r=math.random()*255, g=math.random()*255, b=math.random()*255})
    return id
end

function objectFactory.createElemental(points, center, eleName, initV)
    local initV = initV or Point(0, 0)
    local id = entitySystem.register()
    position.create(id, points, center)
    local ele = element.create(id, eleName)
    collider.create(id, points, center, ele.friction, 'dynamic', eleName == 'ice' or eleName == 'fire', initV)
    local textureName
    if eleName == 'fire' then
        textureName = eleName..'.png'
    else
        textureName = eleName..'.jpg'
    end
    meshRenderer.create(id, ele.color, textureName)
    return id
end

return objectFactory
