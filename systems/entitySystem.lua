local utils = require('utils')
local EntityBuilder = require('systems.EntityBuilder')
local physicsSystem = require('systems.physicsSystem')
local temperatureSystem = require('systems.temperatureSystem')
local graphicsSystem = require('systems.graphicsSystem')
local elementSystem = require('systems.elementSystem')
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
local lifetimeSystem = require('systems.lifetimeSystem')
local spellBookSystem = require('systems.spellBookSystem')
local soundSystem = require('systems.soundSystem')
local Camera = require('camera')
local loader = require "lib.AdvTiledLoader.Loader"
-- set the path to the Tiled map files
loader.path = "maps/"

-- controls registering and deleting entities in the entity system, as well as updating each component system.
local entitySystem = {}

function entitySystem:init(objectFactory)
    self.currId = 0
    self.entities = utils.requireAll('components')
    self.camera = Camera()
    
    local world = love.physics.newWorld(0, 50*conf.tileSize, true)
    
    self.map = loader.load("level1.tmx")
    self.map.tileWidth = conf.tileSize
    self.map.widthInPixels = self.map.tileWidth * self.map.width
    
    graphicsSystem:init(self.camera, self.map, self.entities)
    referenceSystem:init(self.entities)
    physicsSystem:init(world, objectFactory, entitySystem)
    runeSystem:init(objectFactory, self.entities)
    forceSystem:init(world, self.entities)
    jointSystem:init(self.entities)
    temperatureSystem:init(referenceSystem, self.entities)
    elementSystem:init(referenceSystem, self.entities)
    positionSystem:init(referenceSystem, self.entities)
    walkingSystem:init(referenceSystem, self.entities)
    inputSystem:init(referenceSystem, self.entities)
    lifetimeSystem:init(referenceSystem, self)
    experienceSystem:init(referenceSystem, self.entities)
    manaSystem:init(referenceSystem, self.entities)
    healthSystem:init(referenceSystem, self.entities)
    spellBookSystem:init(referenceSystem, self.entities)
    soundSystem:init(referenceSystem, self.entities)
   
    self.builder = EntityBuilder:new(self.entities, self)

    local getIds = function(a, b)
        return a:getUserData(), b:getUserData()
    end
    local beginContact = function(a, b, coll)
        -- If the force of the impact is high enough, shake the screen.
        self.camera:shake(a:getBody(), b:getBody(), coll)
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

function entitySystem:addMapToWorld(objectFactory)
    self.map:addToWorld(objectFactory)
end

function entitySystem:delete(id)
    -- Remove all components from all systems containing this id.
    physicsSystem:delete(id)
    temperatureSystem:delete(id)
    graphicsSystem:delete(id)
    elementSystem:delete(id)
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
    lifetimeSystem:delete(id)
    runeSystem:delete(id)
    soundSystem:delete(id)
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
    elementSystem:update(dt)
    jointSystem:update(dt)
    manaSystem:update(dt)
    healthSystem:update(dt)
    spellBookSystem:update(dt)
    experienceSystem:update(dt)
    walkingSystem:update(dt)
    forceSystem:update(dt)
    soundSystem:update(dt)
    runeSystem:update(dt)
    inputSystem:update(dt)
    lifetimeSystem:update(dt)
    graphicsSystem:update(dt)
end

function entitySystem:draw(raw)
    if not raw then
        self.camera:set()
        graphicsSystem:drawMap()
    end
    graphicsSystem:drawRawComponents()
    forceSystem:draw()
    if not raw then
        self.camera:unset()
        graphicsSystem:drawUI()
    end
    spellBookSystem:draw(heroId)
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
