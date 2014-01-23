local Point = require('geometry.Point')

-- Handles position components.
local positionSystem = {}

require('systems.componentSystem'):inherit(positionSystem)

function positionSystem:init()
    self.components = {}
    self.addQueue = {}
end

function positionSystem:addAndTranslateToCoords(comp)
    if type(comp.coords[1]) ~= 'number' then
        comp.coords = Point.pointsToCoordsTable(comp.coords)
    end
    self:add(comp)
end

function positionSystem:add(comp)
    self.addQueue[comp.id] = comp
end

local shapeInits =
{
    polygon = function initPolygonShape(id, comp)
        local points = Point.coordsToPoints(comp.coords)
        removeRedundantPoints(points)
        centralize(points, computeCentroid(points))
        return love.physics.newPolygonShape(Point.pointsToCoords(points))
    end,
    circle = function initCircleShape(id, comp)
        return love.physics.newCircleShape(comp.radius)
    end,
}

function positionSystem:update(dt)
    if #self.addQueue > 0 then
        for id, comp in pairs(self.addQueue) do
            comp.shape = shapeInits[comp.shapeName](id, comp)
            self.components[id] = comp
        end
        self.addQueue = {}
    end
    for id, comp in pairs(self.components) do
        comp.center.x, comp.center.y = bodySystem:getWorldCenter(id)
        if comp.shapeName == 'polygon' then
            comp.coords = {bodySystem:getWorldPoints(id, comp.shape:getPoints())}
        end
    end
end

function positionSystem:setPos(id, centerX, centerY, coords)
    local comp = self.components[id]
    comp.center.x = centerX
    comp.center.y = centerY
    comp.coords = coords
end

function positionSystem:setCenter(id, centerX, centerY)
    local comp = self.components[id]
    comp.center.x = centerX
    comp.center.y = centerY
end

function positionSystem:getCenter(id)
    return self.components[id].center
end

function positionSystem:getPoints(id)
    return Point.coordsToPoints(self.components[id].coords)
end

function positionSystem:getCoords(id)
    return self.components[id].coords
end

function positionSystem:getRadius(id)
    return self.components[id].radius
end

function positionSystem:getShape(id)
    return self.components[id].shapeName
end

function positionSystem:testPointInRange(point, startId, endId)
    for id = startId, endId do
        if self.components[id] and testPoint(point, Point.coordsToPoints(self.components[id].coords)) then
            return id
        end
    end
    return false
end

return positionSystem
