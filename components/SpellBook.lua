local Spell = require 'Spell'

-- Allows an object in the game world with this component to cast spells it knows.
local SpellBook = require 'lib.middleclass'('SpellBook',
                 require 'components.Component')
SpellBook.static.systems = { require('systems.spellBookSystem'), nonserializable = true }

function SpellBook:initialize(serializedSpellBook)
    self.name = "spellBook"
    self.i = 1
    if not serializedSpellBook then
        self[1] = Spell()
        self[2] = Spell()
        self[3] = Spell()
        self[4] = Spell()
    else
        print('got to serializedSpellBook')
        for i = 1, #serializedSpellBook do
            print('got to serializedSpellBook, i: '..i)
            self[i] = Spell(serializedSpellBook[i])
        end
    end
    self.systems = self.class.static.systems
end

function SpellBook.create(id, ...)
    local c = SpellBook:new(...)
    c:addToSystems(id)
    return c
end

return SpellBook
