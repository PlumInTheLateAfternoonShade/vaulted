local entitySystem = require 'systems.entitySystem'
local positionSystem = require 'systems.positionSystem'

local componentPrototypeDeserializers =
{
    fire = function (table) return require 'systems.element'.fire end,
    earth = function (table) return require 'systems.element'.earth end,
    water = function (table) return require 'systems.element'.water end,
    air = function (table) return require 'systems.element'.air end,
    collider = function (t) return require 'systems.collider'.prototype(t.friction, t.type, t.breakable, t.initV) end,
    position = function (t) return require 'systems.position'.prototype(t.coords, t.center) end,
    meshRenderer = function (t) return require 'systems.meshRenderer'.prototype(t.color, t.imageName) end,
    temperature = function (t) return require 'systems.temperature'.prototype(t.ambientTemp) end,
    force = function (t) return require 'systems.force'.prototype(t.h, t.v, t.x, t.y) end,
}

local function deserializeComponentPrototype(table)
    return componentPrototypeDeserializers[table.name](table)
end

local function constructComponentTables(serializedSpell)
    local compTables = {}
    if not serializedSpell then return compTables end
    for i = 1, #serializedSpell do
        table.insert(compTables, {})
        for j, component in pairs(serializedSpell[i]) do
            compTables[i][j] = objectFactory.deserializeComponentPrototype(component)
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
        for _, component in pairs(self.componentTables[i]) do
            local comp = objectDeepcopy(component)
            if comp.center then 
                -- Adjust the comp's center so it appears where the caster casts it.
                -- TODO offset properly.
                comp.center = positionSystem:getCenter(casterId) end
            comp:addToSystems(id)
        end
    end
end

return Spell
