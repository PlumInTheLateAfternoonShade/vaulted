-- A table of all the hero's spells.

require 'Spell'
require 'utils'

spellBook = {
    Spell(' '),
    Spell('w'),
    Spell('s'),
    Spell('q'),
    i = 1
}

function spellBook.inc(amount)
    wrappedInc(spellBook, amount)
end

function spellBook.keyMatch(key)
    -- Return true and set i to the appropriate spell if
    -- the key matches any of the spell's keys.
    for j = 1, #spellBook do
        if spellBook[j].key == key then
            spellBook.i = j
            return true
        end
    end
    return false
end
