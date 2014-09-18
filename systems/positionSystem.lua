local componentSystem = require('systems.componentSystem')
local Point = require('geometry.Point')

-- Handles position components.
local positionSystem = {}

componentSystem:inherit(positionSystem)

function positionSystem:add(comp)
    if type(comp.coords[1]) ~= 'number' then
        comp.coords = Point.pointsToCoordsTable(comp.coords)
    end
    componentSystem.add(self, comp)
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
    return self.components[id].shape
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
