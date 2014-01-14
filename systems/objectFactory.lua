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
local Spell = require('Spell')

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
    walker.create(id, 10000) -- TODO DEL
    input.create(id) -- TODO DEL
    return id
end

function objectFactory.createPlayer(positionComp, healthComp, manaComp, xpComp, spellBookComp)
    local id = entitySystem:register()
    position.create(id, positionComp.points, positionComp.center)
    -- TODO wrong points
    collider.create(id, 0.5, 'dynamic')
    walker.create(id, 5001)
    input.create(id)
    experience.create(id)
    mana.create(id)
    health.create(id)
    local sB = spellBook.create(id)
    sB[1]:addComponent(force.prototype(id, 0, -1000, 0, 100))

    statBar.create(entitySystem:register(), 0.95, 0.025, {r=230, g=100, b=100},
                   function () return healthSystem:getHealthPercent(id) end)
    statBar.create(entitySystem:register(), 0.975, 0.025, {r=100, g=100, b=230},
                   function () return manaSystem:getManaPercent(id) end)
    polygonRenderer.create(id, {r=255, g=255, b=255})
    return id

end

return objectFactory
