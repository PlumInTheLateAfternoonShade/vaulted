local physicsSystem = require('systems.physicsSystem')
local temperatureSystem = require('systems.temperatureSystem')
local graphicsSystem = require('systems.graphicsSystem')
local eleSystem = require('systems.eleSystem')
local positionSystem = require('systems.positionSystem')
local walkingSystem = require('systems.walkingSystem')
local inputSystem = require('systems.inputSystem')

-- controls registering and deleting entities in the entity system, as well as updating each component system.
local entitySystem = {}
local camera

function entitySystem:init(world, cam, objectFactory)
    self.currId = -1
    camera = cam
    physicsSystem:init(world, objectFactory, entitySystem)
    temperatureSystem:init()
    eleSystem:init()
    positionSystem:init()
    walkingSystem:init()
    inputSystem:init()
    graphicsSystem:init()

    world:setCallbacks(beginContact, endContact, preSolve,
    postSolve)
end

function entitySystem:delete(id)
    -- Remove all components from all systems containing this id.
    physicsSystem:delete(id)
    temperatureSystem:delete(id)
    graphicsSystem:delete(id)
    eleSystem:delete(id)
    positionSystem:delete(id)
    inputSystem:delete(id)
    walkingSystem:delete(id)
end

function entitySystem:update(dt)
    physicsSystem:update(dt)
    temperatureSystem:update(dt)
    eleSystem:update(dt)
    walkingSystem:update(dt)
end

function entitySystem:draw()
    graphicsSystem:draw()
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

function entitySystem:queueDelete(id)
    table.insert(deleteQueue, id)
end

local function getIds(a, b)
    return a:getUserData(), b:getUserData()
end

function beginContact(a, b, coll)
    -- If the force of the impact is high enough, shake the screen.
    camera:shake(a:getBody(), b:getBody(), coll)
    local aId, bId = getIds(a, b)
    physicsSystem:beginCollision(aId, bId, coll)
    temperatureSystem:beginCollision(aId, bId, coll)
end

function endContact(a, b, coll)
    local aId, bId = getIds(a, b)
    physicsSystem:endCollision(aId, bId, coll)
    temperatureSystem:endCollision(aId, bId, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll)
end

return entitySystem
