local physicsSystem = require('systems.physicsSystem')
local graphicsSystem = require('systems.graphicsSystem')
local eleSystem = require('systems.eleSystem')
local positionSystem = require('systems.positionSystem')

-- controls registering and deleting entities in the entity system, as well as updating each component system.
local entitySystem = {}
local currId = -1
local deleteQueue = {}
local camera

function entitySystem.init(world, cam, objectFactory)
    camera = cam
    physicsSystem.init(world, objectFactory, entitySystem)
    world:setCallbacks(beginContact, endContact, preSolve,
    postSolve)
end

local function delete(id)
    -- Remove all components from all systems containing this id.
    physicsSystem.delete(id)
    graphicsSystem.delete(id)
    eleSystem.delete(id)
    positionSystem.delete(id)
end

local function clearDeleteQueue()
    -- Remove all entities that have been flagged for deletion
    
    if #deleteQueue > 0 then printTable("deleteQueue", deleteQueue) end
    each(print, deleteQueue)
    each(delete, deleteQueue)
    deleteQueue = {}
end

function entitySystem.update(dt)
    clearDeleteQueue()    
    physicsSystem.update(dt)
    eleSystem.update(dt)
end

function entitySystem.draw()
    graphicsSystem.draw()
end

-- Returns a new unique entity id. An entity is just an integer.
function entitySystem.register()
    currId = currId + 1
    print('Registering entity '..currId)
    return currId
end

function entitySystem.queueDelete(id)
    table.insert(deleteQueue, id)
end

local function getIds(a, b)
    return a:getUserData(), b:getUserData()
end

function beginContact(a, b, coll)
    -- If the force of the impact is high enough, shake the screen.
    camera:shake(a:getBody(), b:getBody(), coll)
    local aId, bId = getIds(a, b)
    physicsSystem.beginCollision(aId, bId, coll)
end

function endContact(a, b, coll)
    local aId, bId = getIds(a, b)
    physicsSystem.endCollision(aId, bId, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll)
end

return entitySystem
