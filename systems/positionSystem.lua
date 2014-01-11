local Point = require('geometry.Point')

-- Handles position components.
local positionSystem = {}

require('systems.componentSystem'):inherit(positionSystem)

function positionSystem:addAndTranslateToCoords(comp)
    local coords = {}
    for i = 1, #comp.coords do
        local point = comp.coords[i]
        table.insert(coords, point.x)
        table.insert(coords, point.y)
    end
    comp.coords = coords
    self:add(comp)
end

function positionSystem:update(id, center, coords)
    self.components[id].center = center
    self.components[id].coords = coords
end

function positionSystem:getPoints(id)
    local coords = self.components[id].coords
    local points = {}
    if #coords % 2 ~= 0 then print 'EEEEEEEEEEEP!!@!@!@!#!$!!!'
        each(print, coords) end
    for i = 1, #coords, 2 do
        table.insert(points, Point(coords[i], coords[i + 1]))
    end
    return points
end

function positionSystem:getCoords(id)
    return self.components[id].coords
end

return positionSystem
