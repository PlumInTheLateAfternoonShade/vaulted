local spellBookSystem = require 'systems.spellBookSystem'
local Spell = require 'Spell'

-- Allows an object in the game world with this component to cast spells from a pool of spellBook.
local spellBook = {}

function spellBook.create(id, serializedSpellBook)
    local c =
    {
        name = "spellBook",
        i = 1,
    }
    if not serializedSpellBook then
        c[1] = Spell()
    else
        for i, spell in pairs(serializedSpellBook) do
            c[i] = Spell(spell)
        end
    end
    c.id = id
    spellBookSystem:add(c)
    return c
end

return spellBook
