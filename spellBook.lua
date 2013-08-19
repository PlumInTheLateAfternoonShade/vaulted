-- A table of all the hero's spells.

require 'spells.Spell'
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
        if spellBook[j].key == key and table.getn(spellBook[j].lines) ~= 0 then
            spellBook.i = j
            return true
        end
    end
    return false
end

function spellBook.finalize()
    --TODO: should only finalize changed spells?
    for j = 1, #spellBook do
        if #spellBook[j].lines ~= 0 then
            spellBook[j]:finalize()
        end
    end
end
