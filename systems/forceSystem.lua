local positionSystem = require 'systems.positionSystem'
local walkingSystem = require 'systems.walkingSystem'
local element = require 'components.element'
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'

-- Handles force components.
local forceSystem = {}

local latestForce
local forceMult = 10

require('systems.componentSystem'):inherit(forceSystem)

function forceSystem:init(world)
    self.world = world
    self.components = {}
end

local function forceRayCallBack(fixture, x, y, xn, yn, fraction)
    fixture:getBody():applyLinearImpulse(latestForce.h*forceMult, latestForce.v*forceMult)
    return 1
end

local function apply(id, comp, world)
    world:rayCast(comp.x, comp.y, comp.x + comp.h*forceMult,
    comp.y + comp.v*forceMult, forceRayCallBack)
    comp.fired = true
end

function forceSystem:update(dt)
    for id, comp in pairs(self.components) do
        if not comp.fired then
            -- Cache latest force ray cast so the callback can reference it.
            latestForce = comp
            apply(comp.casterId, comp, self.world)
        end
    end
    -- Clear the ray casts.
    --self.components = {}
end

function forceSystem:draw()
    -- TODO replace with particle effect component?
    for id, comp in pairs(self.components) do
        self:drawPreview(Point(comp.x, comp.y), Point(comp.x + comp.h, comp.y + comp.v))
    end
end

function forceSystem:drawPreview(startPoint, endPoint)
    setColor(element.air.color)
    love.graphics.line(startPoint.x, startPoint.y, endPoint.x, endPoint.y)
    local previewSeg = Seg(startPoint, endPoint)
    local angle = previewSeg:getAngle() + math.pi/2
    local length = previewSeg:length()*0.4
    local angOffset = 0.2
    love.graphics.line(endPoint.x, endPoint.y, 
    endPoint.x + math.sin(angle - angOffset)*length,
    endPoint.y + math.cos(angle - angOffset)*length)
    love.graphics.line(endPoint.x, endPoint.y, 
    endPoint.x + math.sin(angle + angOffset)*length,
    endPoint.y + math.cos(angle + angOffset)*length)
end

return forceSystem
