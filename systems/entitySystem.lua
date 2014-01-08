-- controls registering and deleting entities in the entity system, as well as updating each component system.
local entitySystem = {}

local currId = -1
local physicsSystem = require('systems.physicsSystem')
local graphicsSystem = require('systems.graphicsSystem')

function entitySystem.init(world)
    physicsSystem.init(world)
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

return entitySystem
