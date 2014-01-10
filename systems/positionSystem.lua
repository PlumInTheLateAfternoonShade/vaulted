local Point = require('geometry.Point')

-- Handles position components.
local positionSystem = {}

function positionSystem.addAndTranslateToCoords(comp)
    local coords = {}
    for i = 1, #comp.coords do
        local point = comp.coords[i]
        table.insert(coords, point.x)
        table.insert(coords, point.y)
    end
    comp.coords = coords
    positionSystem.add(comp)
end

function positionSystem.add(comp)
    positionSystem[comp.id] = comp
end

function positionSystem.get(id)
    return positionSystem[id]
end

function positionSystem.delete(id)
    positionSystem[id] = nil
end

function positionSystem.update(id, center, coords)
    positionSystem[id].center = center
    positionSystem[id].coords = coords
end

function positionSystem.getPoints(id)
    local coords = positionSystem[id].coords
    local points = {}
    for i = 1, #coords, 2 do
        table.insert(points, Point(coords[i], coords[i + 1]))
    end
    return points
end

function positionSystem.getCoords(id)
    return positionSystem[id].coords
end

return positionSystem
