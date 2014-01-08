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

function positionSystem.update(id, center, coords)
    if positionSystem[id] then
        positionSystem[id].center = center
        positionSystem[id].coords = coords
    end
end

return positionSystem
