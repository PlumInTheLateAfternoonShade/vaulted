local Point = require('geometry.Point')

-- Handles position components.
local positionSystem = {}

require('systems.componentSystem'):inherit(positionSystem)

function positionSystem:addAndTranslateToCoords(comp)
    if type(comp.coords[1]) ~= 'number' then
        comp.coords = Point.pointsToCoordsTable(comp.coords)
    end
    self:add(comp)
end

function positionSystem:update(id, center, coords)
    self.components[id].center = center
    self.components[id].coords = coords
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

function positionSystem:testPointInRange(point, startId, endId)
    for id = startId, endId do
        if self.components[id] and testPoint(point, Point.coordsToPoints(self.components[id].coords)) then
            return id
        end
    end
    return false
end

return positionSystem
