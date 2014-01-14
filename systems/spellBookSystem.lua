local manaSystem = require 'systems.manaSystem'

-- Handles spellBook components.
local spellBookSystem = {}

require('systems.componentSystem'):inherit(spellBookSystem)

function spellBookSystem:cast(id, index)
    if manaSystem:deduct(id, self.components[id][index].power) then
        return self.components[id][index]:cast(id)
    end
end

return spellBookSystem
