require 'lib.deepcopy.deepcopy'
local Point = require 'geometry.Point'
local physicsSystem = require 'systems.physicsSystem'

-- Allows an object in the game world with this component to be collided with.
local collider = {}

function collider.create(id, points, center, friction, type, breakable, initV)
    local c = {}
    c.id = id
    c.center = center
    c.points = {}
    for i = 1, #points do
        c.points[i] = Point(points[i].x, points[i].y)
    end
    c.firstUpdate = true
    c.friction = friction
    c.type = type
    c.breakable = breakable or false
    c.initV = initV or Point(0, 0)
    c.maxMassToBreak = 40
    physicsSystem:add(c)
    return c
end

return collider
