local entitySystem = require 'systems.entitySystem'
local positionSystem = require 'systems.positionSystem'

-- Defines a spell that can be cast by a caster.
-- A spell consists of a table of component prototype tables.
-- When cast, it copys and adds each component to the appropriate systems.
local Spell = require 'class'
{
    name = 'Spell',
    function(self)
        self.power = 0.1
        self.componentTables = {}
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
