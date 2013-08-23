-- A table of all the hero's spells.

local Spell = require 'spells.Spell'
require 'utils'
local Class = require 'class'

local defaultSpellBookTable =
{
    i = 1,
    Spell(spell1),
    Spell(spell2),
    Spell(spell3),
    Spell(spell4)
}

local SpellBook = Class
{
    name = 'SpellBook',
    function(self, table)
        self:selfConstruct(table or defaultSpellBookTable)
    end
}

function SpellBook:selfConstruct(table)
    self.i = table.i
    for j = 1, #table do
        self[j] = Spell(spellKey[j], table[j])
    end
end

function SpellBook:inc(amount)
    wrappedInc(self, amount)
end

function SpellBook:keyMatch(key)
    -- Return true and set i to the appropriate spell if
    -- the key matches any of the spell's keys.
    for j = 1, #self do
        if self[j].key == key and table.getn(self[j].lines) ~= 0 then
            self.i = j
            return true
        end
    end
    return false
end

function SpellBook:finalize()
    --TODO: should only finalize changed spells?
    for j = 1, #self do
        if #self[j].lines ~= 0 then
            self[j]:finalize()
        end
    end
end

return SpellBook
