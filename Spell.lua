local utils = require 'utils'
local positionSystem = require 'systems.positionSystem'
local walkingSystem = require 'systems.walkingSystem'
local Point = require 'geometry.Point'
local builder

local function constructComponentTables(serializedSpell)
    if not serializedSpell or not serializedSpell.componentTables then
        return {}
    end
    for i = 1, #serializedSpell.componentTables do
        for j = 1, #serializedSpell.componentTables[i] do
            local comp = serializedSpell.componentTables[i][j]
            assert(comp)
            if comp.firstUpdate == false then
                comp.firstUpdate = true
            end
        end
    end
    return serializedSpell.componentTables 
end

-- Defines a spell that can be cast by a caster.
-- A spell consists of a table of component prototype tables.
-- When cast, it copys and adds each component to the appropriate systems.
local Spell = require 'lib.middleclass'('Spell')
 
function Spell:initialize(entityBuilder, serializedSpell)
    self.power = 0.1
    builder = entityBuilder
    self.componentTables = constructComponentTables(serializedSpell)
end

function Spell:addComponentTable(compTable)
    table.insert(self.componentTables, compTable)
end

local function adjustPositionForCaster(x, y, facing, casterId)
    return (x - conf.screenWidth*0.5 - conf.tileSize)*facing +
           positionSystem:getCenter(casterId).x,
           y - conf.screenHeight*0.5 + positionSystem:getCenter(casterId).y
end

local function adjustPositionPointForCaster(point, facing, casterId)
    point.x, point.y = adjustPositionForCaster(point.x, point.y,
                                               facing, casterId)
    return point
end

function Spell:cast(casterId)
    local facing = walkingSystem:get(casterId).facing
    for i = 1, #self.componentTables do
        builder:withNewId()
        for j = 1, #self.componentTables[i] do
            assert(self.componentTables[i][j])
            local comp = utils.objectDeepcopyWithoutMetatable(
                self.componentTables[i][j])
            if comp.firstUpdate == false then
                comp.firstUpdate = true
            end
            -- Adjust the comp's pos so it appears where the caster casts it.
            if comp.center then 
                adjustPositionPointForCaster(comp.center, facing, casterId)
            end
            if comp.coords and facing == -1 then
                comp.coords = Point.pointsToCoordsTable(
                Point.mirrorXListOfPoints(
                Point.coordsToPoints(comp.coords)))
            end
            if comp.x and comp.y and comp.h and comp.v then
                comp.x, comp.y = adjustPositionForCaster(comp.x, comp.y,
                                                         facing, casterId)
                comp.h = comp.h * facing
            end
            if comp.casterId then
                comp.casterId = casterId
            end
            builder:add(comp)
        end
    end
end

function Spell:preview()
    for i = 1, #self.componentTables do
        self.componentTables[i].previewId = builder:withNewId().inUseId
        for j = 1, #self.componentTables[i] do
            local component = self.componentTables[i][j]
            if component.shouldPreview then
                builder:add(component)
            end
        end
    end
end

function Spell:addComponentToEntity(component, previewId)
    for i = 1, #self.componentTables do
        if self.componentTables[i].previewId == previewId then
            table.insert(self.componentTables[i], component)
            return
        end
    end
end

function Spell:delete(id)
    for i = #self.componentTables, 1, -1 do
        print(i)
        print(self.componentTables[i].previewId)
        if self.componentTables[i].previewId == id then
            table.remove(self.componentTables, i)
        end
    end
end

return Spell
