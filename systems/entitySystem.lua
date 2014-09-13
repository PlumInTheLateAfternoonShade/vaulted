local physicsSystem = require('systems.physicsSystem')
local temperatureSystem = require('systems.temperatureSystem')
local graphicsSystem = require('systems.graphicsSystem')
local eleSystem = require('systems.eleSystem')
local jointSystem = require('systems.jointSystem')
local referenceSystem = require('systems.referenceSystem')
local positionSystem = require('systems.positionSystem')
local walkingSystem = require('systems.walkingSystem')
local inputSystem = require('systems.inputSystem')
local experienceSystem = require('systems.experienceSystem')
local manaSystem = require('systems.manaSystem')
local healthSystem = require('systems.healthSystem')
local forceSystem = require('systems.forceSystem')
local runeSystem = require('systems.runeSystem')
local spellBookSystem = require('systems.spellBookSystem')
local Camera = require('camera')
local loader = require "lib.AdvTiledLoader.Loader"
-- set the path to the Tiled map files
loader.path = "maps/"

-- controls registering and deleting entities in the entity system, as well as updating each component system.
local entitySystem = {}

function entitySystem:init(objectFactory)
    self.currId = -1
    
    local camera = Camera()
    
    local world = love.physics.newWorld(0, 50*conf.tileSize, true)
    
    local map = loader.load("level1.tmx")
    map.tileWidth = conf.tileSize
    map.widthInPixels = map.tileWidth * map.width
    
    graphicsSystem:init(camera, map)
    referenceSystem:init()
    physicsSystem:init(world, objectFactory, entitySystem)
    runeSystem:init(objectFactory)
    forceSystem:init(world)
    jointSystem:init()
    temperatureSystem:init(referenceSystem)
    eleSystem:init(referenceSystem)
    positionSystem:init(referenceSystem)
    walkingSystem:init(referenceSystem)
    inputSystem:init(referenceSystem)
    experienceSystem:init(referenceSystem)
    manaSystem:init(referenceSystem)
    healthSystem:init(referenceSystem)
    spellBookSystem:init(referenceSystem)
    
    map:addToWorld(objectFactory)
    
    local getIds = function(a, b)
        return a:getUserData(), b:getUserData()
    end
    local beginContact = function(a, b, coll)
        -- If the force of the impact is high enough, shake the screen.
        camera:shake(a:getBody(), b:getBody(), coll)
        local aId, bId = getIds(a, b)
        physicsSystem:beginCollision(aId, bId, coll)
        temperatureSystem:beginCollision(aId, bId, coll)
    end
    local endContact = function(a, b, coll)
        local aId, bId = getIds(a, b)
        physicsSystem:endCollision(aId, bId, coll)
        temperatureSystem:endCollision(aId, bId, coll)
    end
    local preSolve = function(a, b, coll)
    end
    local postSolve = function(a, b, coll, normalImpulse1,
        tangentImpulse1, normalImpulse2, tangentImpulse2)
        local aId, bId = getIds(a, b)
        physicsSystem:postSolveCollision(aId, bId, coll, normalImpulse1,
            tangentImpulse1, normalImpulse2, tangentImpulse2)
    end
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function entitySystem:delete(id)
    -- Remove all components from all systems containing this id.
    physicsSystem:delete(id)
    temperatureSystem:delete(id)
    graphicsSystem:delete(id)
    eleSystem:delete(id)
    jointSystem:delete(id)
    referenceSystem:delete(id)
    positionSystem:delete(id)
    inputSystem:delete(id)
    experienceSystem:delete(id)
    manaSystem:delete(id)
    healthSystem:delete(id)
    spellBookSystem:delete(id)
    walkingSystem:delete(id)
    forceSystem:delete(id)
    runeSystem:delete(id)
end

function entitySystem:deleteAllInRange(lowerId, upperId)
    for id = lowerId, upperId do
        self:delete(id)
    end
end

function entitySystem:update(dt)
    physicsSystem:update(dt)
    temperatureSystem:update(dt)
    referenceSystem:update(dt)
    eleSystem:update(dt)
    jointSystem:update(dt)
    manaSystem:update(dt)
    healthSystem:update(dt)
    spellBookSystem:update(dt)
    experienceSystem:update(dt)
    walkingSystem:update(dt)
    forceSystem:update(dt)
    runeSystem:update(dt)
    graphicsSystem:update(dt)
end

function entitySystem:draw(raw)
    graphicsSystem:draw(raw)
    spellBookSystem:draw(heroId)
    forceSystem:draw()
end

function entitySystem:keyPressed(key)
    inputSystem:keyPressed(key)
end

function entitySystem:keyReleased(key)
    inputSystem:keyReleased(key)
end

-- Returns a new unique entity id. An entity is just an integer.
function entitySystem:register()
    self.currId = self.currId + 1
    return self.currId
end

return entitySystem
