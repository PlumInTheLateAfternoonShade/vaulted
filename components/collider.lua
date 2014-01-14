require 'lib.deepcopy.deepcopy'
local Point = require 'geometry.Point'
local physicsSystem = require 'systems.physicsSystem'

-- Allows an object in the game world with this component to be collided with.
local collider = {}

function collider.prototype(friction, type, breakable, initV)
    local c = {}
    c.firstUpdate = true
    c.friction = friction
    c.type = type
    c.breakable = breakable or false
    c.initV = initV or Point(0, 0)
    c.maxMassToBreak = 40
    function c:addToSystems(id)
        self.id = id
        physicsSystem:add(self)
    end
    return c
end

function collider.create(id, friction, type, breakable, initV)
    local c = collider.prototype(friction, type, breakable, initV)
    c:addToSystems(id)
    return c
end

return collider
