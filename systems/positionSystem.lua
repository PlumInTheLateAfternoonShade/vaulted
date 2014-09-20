local Point = require('geometry.Point')
local Position = require('components.Position')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles position components.
local PositionSystem = require('lib.middleclass')(
    'PositionSystem', ComponentSystem)

function PositionSystem:init(referenceSystem, entities)
    self.components = entities[Position]
    print("# in pos: "..#self.components)
    ComponentSystem.init(self, referenceSystem)
end

function PositionSystem:add(comp)
    if type(comp.coords[1]) ~= 'number' then
        comp.coords = Point.pointsToCoordsTable(comp.coords)
    end
    self.components[comp.id] = comp
end

function PositionSystem:setPos(id, centerX, centerY, coords)
    local comp = self.components[id]
    comp.center.x = centerX
    comp.center.y = centerY
    comp.coords = coords
end

function PositionSystem:setCenter(id, centerX, centerY)
    local comp = self.components[id]
    comp.center.x = centerX
    comp.center.y = centerY
end

function PositionSystem:getCenter(id)
    return self.components[id].center
end

function PositionSystem:getPoints(id)
    return Point.coordsToPoints(self.components[id].coords)
end

function PositionSystem:getCoords(id)
    return self.components[id].coords
end

function PositionSystem:getRadius(id)
    return self.components[id].radius
end

function PositionSystem:getShape(id)
    return self.components[id].shape
end

function PositionSystem:testPointInRange(point, startId, endId)
    for id = startId, endId do
        if self.components[id] and testPoint(point, Point.coordsToPoints(self.components[id].coords)) then
            return id
        end
    end
    return false
end

local positionSystemInstance = PositionSystem:new()
return positionSystemInstance
