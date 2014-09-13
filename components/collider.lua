local Point = require 'geometry.Point'
local physicsSystem = require 'systems.physicsSystem'

-- Allows an object in the game world with this component to be collided with.
local collider = {}

function collider.prototype(friction, type, breakable, initV, density,
    shouldBalance, shouldPierce, hardness)
    local c = { name = 'collider' }
    c.firstUpdate = true
    c.friction = friction
    c.type = type
    c.breakable = breakable or false
    c.initV = initV or Point(0, 0)
    c.density = density
    c.shouldBalance = shouldBalance or false
    c.shouldPierce = shouldPierce or false
    c.hardness = hardness or 5
    c.maxMassToBreak = 40
    function c:addToSystems(id)
        self.id = id
        physicsSystem:add(self)
    end
    return c
end

function collider.create(id, ...)
    local c = collider.prototype(...)
    c:addToSystems(id)
    return c
end

return collider
