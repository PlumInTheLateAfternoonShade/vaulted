-- controls registering and deleting entities in the entity system, as well as updating each component system.
local entitySystem = {}

local currId = -1
local physicsSystem = require('systems.physicsSystem')
local graphicsSystem = require('systems.graphicsSystem')
local camera

function entitySystem.init(world, cam)
    camera = cam
    physicsSystem.init(world)
    world:setCallbacks(beginContact, endContact, preSolve,
    postSolve)
end

function entitySystem.update(dt)
    physicsSystem.update(dt)
end

function entitySystem.draw()
    graphicsSystem.draw()
end

-- Returns a new unique entity id. An entity is just an integer.
function entitySystem.register()
    currId = currId + 1
    return currId
end

function entitySystem.delete(id)
    -- Remove all components from all systems containing this id.
    -- Update the last component to have this id instead.
    if physicsSystem[id] then
        physicsSystem[id] = physicsSystem[#physicsSystem]
        table.remove(physicsSystem)
    end
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
