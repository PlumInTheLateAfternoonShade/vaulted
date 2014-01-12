local manaSystem = require('systems.manaSystem')

-- Allows an object in the game world with this component to cast spells from a pool of mana.
local mana = {}

function mana.create(id, initMana, manaMult)
    local c = {}
    c.id = id
    c.mana = initMana or 0
    c.manaMult = manaMult or 1
    manaSystem:add(c)
    return c
end

return mana
