local entitySystem = require('systems.entitySystem')
local manaSystem = require('systems.manaSystem')
local healthSystem = require('systems.healthSystem')
local collider = require('components.collider')
local polygonRenderer = require('components.polygonRenderer')
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

-- Convenience functions to create objects in the entity component system.
local objectFactory = {}

function objectFactory.init(world, cam, map)
    entitySystem:init(world, cam, map, objectFactory)
end

function objectFactory.createTile(points, center)
    local id = entitySystem:register()
    position.create(id, points, center)
    collider.create(id, 0.5, 'static')
    polygonRenderer.create(id, {r=math.random()*255, g=math.random()*255, b=math.random()*255})
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

function objectFactory.createPlayer(serializedPosition, serializedSpellBook)
    local id = entitySystem:register()
    position.create(id, serializedPosition.points, serializedPosition.center)
    collider.create(id, 0.5, 'dynamic')
    walker.create(id, 5001)
    input.create(id)
    experience.create(id)
    mana.create(id)
    health.create(id)
    spellBook.create(id, serializedSpellBook)
    statBar.create(entitySystem:register(), 0.95, 0.025, {r=230, g=100, b=100},
                   function () return healthSystem:getHealthPercent(id) end)
    statBar.create(entitySystem:register(), 0.975, 0.025, {r=100, g=100, b=230},
                   function () return manaSystem:getManaPercent(id) end)
    polygonRenderer.create(id, {r=255, g=255, b=255})
    return id

end


local componentPrototypeDeserializers =
{
    fire = function (table) return element.fire end,
    earth = function (table) return element.earth end,
    water = function (table) return element.water end,
    air = function (table) return element.air end,
    collider = function (t) return collider.prototype(t.friction, t.type, t.breakable, t.initV) end,
    position = function (t) return position.prototype(t.coords, t.center) end,
    meshRenderer = function (t) return meshRenderer.prototype(t.color, t.imageName) end,
    temperature = function (t) return temperature.prototype(t.ambientTemp) end,
    force = function (t) return force.prototype(t.h, t.v, t.x, t.y) end,
}

function objectFactory.deserializeComponentPrototype(table)
    return componentPrototypeDeserializers[table.name](table)
end

return objectFactory
