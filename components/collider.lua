require 'lib.deepcopy.deepcopy'
local Point = require 'geometry.Point'
local physicsSystem = require 'systems.physicsSystem'

-- Allows an object in the game world with this component to be collided with.
local collider = {}

function collider.create(id, points, center, friction, type, breakable)
    local c = {}
    c.id = id
    local t = savedSelf or {points = points, center = center}
    c.center = t.center
    c.points = {}
    for i = 1, #t.points do
        c.points[i] = Point(t.points[i].x, t.points[i].y)
    end
    c.firstUpdate = true
    c.friction = friction
    c.type = type
    c.breakable = breakable or false
    c.maxMassToBreak = 10
    physicsSystem.add(c)
    return c
end

return collider
