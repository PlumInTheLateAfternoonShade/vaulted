-- Defines a spell that can be cast by a caster.
local Spell = require 'class'
{
    name = 'Spell',
    function(self)
        self.power = 0.1
        self.components = {}
    end
}

function Spell:addComponent(comp)
    table.insert(self.components, comp)
end

function Spell:cast(id)
    for _, comp in pairs(self.components) do
        if comp.center then 
            -- Adjust the comp's center so it appears where the caster casts it.
            -- TODO offset properly.
            comp.center = positionSystem:getCenter(id) end
        comp:addToSystems()
    end
end

return Spell
