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
    collider = function (t) return require 'components.collider'.prototype(t.friction, t.type, t.breakable, t.initV) end,
    position = function (t) return require 'components.position'.prototype(t.coords, t.center) end,
    meshRenderer = function (t) return require 'components.meshRenderer'.prototype(t.color, t.imageName) end,
    temperature = function (t) return require 'components.temperature'.prototype(t.ambientTemp) end,
    force = function (t) return require 'components.force'.prototype(t.h, t.v, t.x, t.y, t.casterId) end,
    input = function (t) return require 'components.input'.prototype(t.canAdministrate, t.canCast) end,
    walker = function (t) return require 'components.walker'.prototype(t.force) end,
}

local function deserializeComponentPrototype(table)
    return componentPrototypeDeserializers[table.name](table)
end

local function constructComponentTables(serializedSpell)
    local compTables = {}
    if not serializedSpell or not serializedSpell.componentTables then return compTables end
    for i = 1, #serializedSpell.componentTables do
        table.insert(compTables, {})
        for j = 1, #serializedSpell.componentTables[i] do
            compTables[i][j] = deserializeComponentPrototype(serializedSpell.componentTables[i][j])
        end
    end
    return compTables
end

-- Defines a spell that can be cast by a caster.
-- A spell consists of a table of component prototype tables.
-- When cast, it copys and adds each component to the appropriate systems.
local Spell = require 'class'
{
    name = 'Spell',
    function(self, serializedSpell)
        self.power = 0.1
        self.componentTables = constructComponentTables(serializedSpell)
    end
}

function Spell:addComponentTable(compTable)
    table.insert(self.componentTables, compTable)
end

function Spell:cast(casterId)
    for i = 1, #self.componentTables do
        local id = entitySystem:register()
        for j = 1, #self.componentTables[i] do
            local comp = objectDeepcopy(self.componentTables[i][j])
            if comp.center then 
                -- Adjust the comp's center so it appears where the caster casts it.
                local facing = walkingSystem:get(casterId).facing
                comp.center = Point(comp.center.x*facing - conf.screenWidth * 0.5, comp.center.y - conf.screenHeight * 0.5)
                    + positionSystem:getCenter(casterId)
                if facing == -1 then
                    comp.coords = Point.pointsToCoordsTable(Point.mirrorXListOfPoints(positionSystem:getPoints(casterId)))
                end
            end
            if comp.casterId then
                comp.casterId = casterId
            end
            comp:addToSystems(id)
        end
    end
    inputSystem:syncAllWithKeys()
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
