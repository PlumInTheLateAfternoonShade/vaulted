local positionSystem = require 'systems.positionSystem'
local walkingSystem = require 'systems.walkingSystem'

-- Handles force components.
local forceSystem = {}

local latestForce
local forceMult = 1000

require('systems.componentSystem'):inherit(forceSystem)

function forceSystem:init(world)
    self.world = world
    self.components = {}
end

local function mirrorIfLeftFacing(x, h, direction)
    if direction ~= -1 then
        return x, h
    end
    return x * direction, h * direction
end

local function forceRayCallBack(fixture, x, y, xn, yn, fraction)
    fixture:getBody():applyLinearImpulse(latestForce.h*forceMult, latestForce.v*forceMult)
    return 1
end

local function apply(id, comp, world)
    local x, h = mirrorIfLeftFacing(comp.x, comp.h, walkingSystem:getDirection(id))
    local y = comp.y
    local v = comp.v
    local center = positionSystem:getCenter(id)
    local adjX = center.x + x
    local adjY = center.y + y
    world:rayCast(adjX, adjY, adjX + h*forceMult, adjY + v*forceMult, forceRayCallBack)
    print('Applying a force at '..string.format("x: %.2f, y: %.2f, h: %.2f, v: %.2f", adjX, adjY, h, v))
end

function forceSystem:update(dt)
    for id, comp in pairs(self.components) do
        -- Cache latest force ray cast so the callback can reference it.
        latestForce = comp
        apply(comp.casterId, comp, self.world)
    end
    -- Clear the ray casts.
    self.components = {}
end

function forceSystem:draw()
    -- TODO replace with particle effect component?
    for id, comp in pairs(self.components) do
        setColor({r = 255, g = 255, b = 255})
        love.graphics.line(comp.x, comp.y, comp.x + comp.h, comp.y + comp.v)
    end
end

return forceSystem
