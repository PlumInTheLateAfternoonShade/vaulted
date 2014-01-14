local spellBookSystem = require 'systems.spellBookSystem'
local Spell = require 'Spell'

-- Allows an object in the game world with this component to cast spells from a pool of spellBook.
local spellBook = {}

function spellBook.create(id)
    local c =
    {
        i = 1,
        Spell(),
        Spell(),
        Spell(),
        Spell()
    }
    c.id = id
    spellBookSystem:add(c)
    return c
end

return spellBook
