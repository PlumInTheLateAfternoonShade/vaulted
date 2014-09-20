local entitySystem = require('systems.entitySystem')
local manaSystem = require('systems.manaSystem')
local healthSystem = require('systems.healthSystem')
local Collider = require('components.Collider')
local ElementInstance = require('components.ElementInstance')
local MeshRenderer = require('components.MeshRenderer')
local Position = require('components.Position')
local element = require('components.element')
local Temperature = require('components.Temperature')
local Point = require('geometry.Point')
local builder

-- Convenience functions to create objects in the entity component system.
local objectFactory = {}

function objectFactory.init()
    entitySystem:init(objectFactory)
    builder = entitySystem.builder
    entitySystem:addMapToWorld(objectFactory)
end

function objectFactory.createTile(points, center)
    local id = builder:withNewId().inUseId
    builder:Position(points, center)
    :Collider(0.5, 'static')
    -- Draws the tile as a polygon. Uncomment for debugging.
    --:ShapeRenderer({r=math.random()*255, g=math.random()*255, b=math.random()*255})
    builder:finalize()
    return id
end

function objectFactory.createElemental(points, center, eleName, initV)
    local ele = element[eleName]
    local initV = initV or Point(0, 0)
    local textureName
    if eleName == 'fire' then
        textureName = eleName..'.png'
    else
        textureName = eleName..'.jpg'
    end
    local id = builder:withNewId().inUseId
    builder:Position(points, center)
    :Collider(ele.friction, 'dynamic', eleName == 'ice' or eleName == 'fire', initV, ele.density, false, true, ele.hardness)
    :ElementInstance(eleName)
    :MeshRenderer(ele.color, textureName)
    :Temperature(ele.temp)
    :finalize()
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
    local previewId = builder:withNewId().inUseId
    local _, pos = builder:Position(points, center)
    local _, meshR = builder:MeshRenderer(ele.color, textureName)
    builder:finalize()
    return
    {
        
        ElementInstance:new(eleName),
        Collider:new(ele.friction, --friction
                           'dynamic', --type
                           eleName == 'ice' or eleName == 'fire', --breakable
                           nil, --initV
                           ele.density, --density
                           false, --shouldBalance
                           true, --shouldPierce
                           ele.hardness --hardness
                           ),
        pos,
        meshR,
        Temperature:new(ele.temp),
        previewId = previewId
    }
end

function objectFactory.prototypeForce(h, v, x, y, casterId)
    local _, forceComp = builder:withNewId():Force(h, v, x, y, casterId)
    local id = builder.inUseId
    builder:finalize()
    return {forceComp, previewId = id}
end

local playerFriction = 0.5

local function createBipedalLeg(parentId, weldPoint, center, legRadius)
    local legId = builder:withNewId().inUseId
    builder:Referencer(parentId)
    :Position({}, center, 'circle', legRadius)
    :Collider(playerFriction, 'dynamic', false, nil, nil, true)
    :ShapeRenderer({r=math.random()*255, g=255, b=255})
    :withNewId()
    :Welder(parentId, legId, weldPoint)
    :finalize()
end

function objectFactory.createPlayer(serializedPosition, serializedSpellBook)
    local id = builder:withNewId().inUseId
    builder:Position(serializedPosition.points, serializedPosition.center)
--, type, breakable, initV, density,
--    shouldBalance, shouldPierce, hardness
    :Collider(playerFriction, --friction
        'dynamic', --type
        false, --breakable
        nil, --initV 
        nil, --density
        true) --shouldBalance
    :ShapeRenderer({r=255, g=255, b=255})
    :SpellBook(builder, serializedSpellBook)
    :Walker(250, 400)
    :Input()
    :Experience()
    :Mana()
    :Health()
    local playerLegOffsetLeft = serializedPosition.center + Point(-conf.tileSize, conf.tileSize)
    local playerLegOffsetRight = serializedPosition.center + Point(conf.tileSize, conf.tileSize)
    createBipedalLeg(id, playerLegOffsetLeft, playerLegOffsetLeft, 15)
    createBipedalLeg(id, playerLegOffsetRight, playerLegOffsetRight, 15)
    builder:withNewId():StatBar(0.95, 0.025, {r=230, g=100, b=100},
                   function () return healthSystem:getHealthPercent(id) end)
    :withNewId():StatBar(0.975, 0.025, {r=100, g=100, b=230},
                   function () return manaSystem:getManaPercent(id) end)
    :finalize()
    return id
end

function objectFactory.createWelder(id1, id2, point, shouldCollide)
    return builder:withNewId()
    :Welder(id1, id2, point, shouldCollide)
    .inUseId
end

return objectFactory
