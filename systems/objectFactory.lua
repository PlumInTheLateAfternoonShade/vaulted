local entitySystem = require('systems.entitySystem')
local manaSystem = require('systems.manaSystem')
local healthSystem = require('systems.healthSystem')
local collider = require('components.collider')
local shapeRenderer = require('components.shapeRenderer')
local meshRenderer = require('components.meshRenderer')
local position = require('components.position')
local element = require('components.element')
local temperature = require('components.temperature')
local mana = require('components.mana')
local health = require('components.health')
local statBar = require('components.statBar')
local experience = require('components.experience')
local walker = require('components.walker')
local input = require('components.input')
local spellBook = require('components.spellBook')
local force = require('components.force')
local welder = require('components.welder')
local referencer = require('components.referencer')
local Point = require('geometry.Point')

-- Convenience functions to create objects in the entity component system.
local objectFactory = {}

function objectFactory.init()
    entitySystem:init(objectFactory)
end

function objectFactory.createTile(points, center)
    local id = entitySystem:register()
    position.create(id, points, center)
    collider.create(id, 0.5, 'static')
    -- Draws the tile as a polygon. Uncomment for debugging.
    --shapeRenderer.create(id, {r=math.random()*255, g=math.random()*255, b=math.random()*255})
    return id
end

function objectFactory.createElemental(points, center, eleName, initV)
    local initV = initV or Point(0, 0)
    local id = entitySystem:register()
    position.create(id, points, center)
    local ele = element.create(id, eleName)
    collider.create(id, ele.friction, 'dynamic', eleName == 'ice' or eleName == 'fire', initV)
    local textureName
    if eleName == 'fire' then
        textureName = eleName..'.png'
    else
        textureName = eleName..'.jpg'
    end
    meshRenderer.create(id, ele.color, textureName)
    temperature.create(id, ele.temp)
    return id
end

function objectFactory.prototypeElemental(points, center, eleName)
    local ele = element[eleName]
    local textureName
    if eleName == 'fire' then
        textureName = eleName..'.png'
    else
        textureName = eleName..'.jpg'
    end
    local meshR = meshRenderer.prototype(ele.color, textureName)
    local pos = position.prototype(points, center)
    local previewId = entitySystem:register()
    meshR:addToSystems(previewId)
    pos:addToSystems(previewId)
    return
    {
        ele,
        collider.prototype(ele.friction, 'dynamic', eleName == 'ice' or eleName == 'fire'),
        position.prototype(points, center),
        meshR,
        temperature.prototype(ele.temp),
        previewId = previewId
    }
end

function objectFactory.prototypeForce(h, v, x, y, casterId)
    local forceComp = force.prototype(h, v, x, y, casterId)
    local previewId = entitySystem:register()
    forceComp:addToSystems(previewId)
    return {forceComp, previewId = previewId}
end

local playerFriction = 0.5

local function createBipedalLeg(parentId, weldPoint, center, legRadius)
    local legId = entitySystem:register()
    referencer.create(legId, parentId)
    position.create(legId, {}, center, 'circle', legRadius)
    shapeRenderer.create(legId, {r=math.random()*255, g=255, b=255})
    collider.create(legId, playerFriction, 'dynamic', false, nil, nil, true)
    local weldId = entitySystem:register()
    welder.create(weldId, parentId, legId, weldPoint)
end

function objectFactory.createPlayer(serializedPosition, serializedSpellBook)
    local id = entitySystem:register()
    position.create(id, serializedPosition.points, serializedPosition.center)
    collider.create(id, playerFriction, 'dynamic', false, nil, nil, true)
    walker.create(id, 250, 400)
    input.create(id)
    experience.create(id)
    mana.create(id)
    health.create(id)
    spellBook.create(id, serializedSpellBook)
    statBar.create(entitySystem:register(), 0.95, 0.025, {r=230, g=100, b=100},
                   function () return healthSystem:getHealthPercent(id) end)
    statBar.create(entitySystem:register(), 0.975, 0.025, {r=100, g=100, b=230},
                   function () return manaSystem:getManaPercent(id) end)
    shapeRenderer.create(id, {r=255, g=255, b=255})
    local playerLegOffsetLeft = serializedPosition.center + Point(-conf.tileSize, conf.tileSize)
    local playerLegOffsetRight = serializedPosition.center + Point(conf.tileSize, conf.tileSize)
    createBipedalLeg(id, playerLegOffsetLeft, playerLegOffsetLeft, 15)
    createBipedalLeg(id, playerLegOffsetRight, playerLegOffsetRight, 15)
    return id
end

return objectFactory
