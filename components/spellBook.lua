local spellBookSystem = require('systems.spellBookSystem')

-- Allows an object in the game world with this component to cast spells from a pool of spellBook.
local spellBook = {}

function spellBook.create(id)
    local c =
    {
        i = 1,
        Spell(spell1),
        Spell(spell2),
        Spell(spell3),
        Spell(spell4)
    }
    c.id = id
    spellBookSystem:add(c)
    return c
end

return spellBook
