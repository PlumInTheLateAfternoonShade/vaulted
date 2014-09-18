local utils = require 'utils'
local entitySystem = require 'systems.entitySystem'
local positionSystem = require 'systems.positionSystem'
local walkingSystem = require 'systems.walkingSystem'
local inputSystem = require 'systems.inputSystem'
local Point = require 'geometry.Point'

local componentPrototypeDeserializers =
{
    fire = function (table) return require 'components.element'.fire end,
    earth = function (table) return require 'components.element'.earth end,
    ice = function (table) return require 'components.element'.ice end,
    air = function (table) return require 'components.element'.air end,
    collider = function (t) return require 'components.collider'.prototype(t.friction, t.type, t.breakable, t.initV,
                                                                           t.density,
                                                                           t.shouldBalance,
                                                                           t.shouldPierce,
                                                                           t.hardness) end,
    position = function (t) return require 'components.Position':new(t.coords, t.center) end,
    meshRenderer = function (t) return require 'components.meshRenderer'.prototype(t.color, t.imageName) end,
    temperature = function (t) return require 'components.temperature'.prototype(t.ambientTemp) end,
    force = function (t) 
        print("force built.")
        return require 'components.Force':new(t.h, t.v, t.x, t.y, t.casterId)
    end,
    input = function (t) return require 'components.input'.prototype(t.canAdministrate, t.canCast) end,
    walker = function (t) return require 'components.walker'.prototype(t.force) end,
}

local function deserializeComponentPrototype(table)
    return componentPrototypeDeserializers[table.name](table)
end

local function constructComponentTables(serializedSpell)
    local compTables = {}
    if not serializedSpell or not serializedSpell.componentTables then
        return compTables
    end
    return serializedSpell.componentTables
    --[[for i = 1, #serializedSpell.componentTables do
        table.insert(compTables, {})
        for j = 1, #serializedSpell.componentTables[i] do
            compTables[i][j] = deserializeComponentPrototype(serializedSpell.componentTables[i][j])
        end
    end
    return compTables]]--
end

-- Defines a spell that can be cast by a caster.
-- A spell consists of a table of component prototype tables.
-- When cast, it copys and adds each component to the appropriate systems.
local Spell = require 'lib.middleclass'('Spell')
 
function Spell:initialize(serializedSpell)
    print("initialized. serializedSpell: "..tostring(serializedSpell))
    self.power = 0.1
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
        local id = entitySystem:register()
        for j = 1, #self.componentTables[i] do
            local comp = utils.objectDeepcopyWithoutMetatable(
                self.componentTables[i][j])
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
                print("got here. x:"..comp.x.." y: "..comp.y.." h: "..comp.h.." v: "..comp.v)
                comp.x, comp.y = adjustPositionForCaster(comp.x, comp.y,
                                                         facing, casterId)
                comp.h = comp.h * facing
                print("x:"..comp.x.." y: "..comp.y.." h: "..comp.h.." v: "..comp.v)
            end
            if comp.casterId then
                comp.casterId = casterId
            end
            print(j.." spell loop ")
            comp:addToSystems(id)
            print(j.." spell loop pos: "..tostring(positionSystem:get(168)))
        end
    end
    inputSystem:syncAllWithKeys()
    print("spell pos: "..tostring(positionSystem.components[168]))
end

function Spell:preview()
    for i = 1, #self.componentTables do
        local id = entitySystem:register()
        self.componentTables[i].previewId = id
        for j = 1, #self.componentTables[i] do
            local component = self.componentTables[i][j]
            if component.shouldPreview then
                component:addToSystems(id)
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
