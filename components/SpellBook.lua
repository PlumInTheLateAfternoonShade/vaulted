local Spell = require 'Spell'
local CoolDownMetro = require 'CoolDownMetro'

-- Allows an object in the game world with this component to cast spells it knows.
local SpellBook = require 'lib.middleclass'('SpellBook',
                 require 'components.Component')

function SpellBook:initialize(builder, serializedSpellBook)
    self.coolDown = CoolDownMetro:new(0.4)
    self.i = 1
    if not serializedSpellBook then
        self[1] = Spell(builder)
        self[2] = Spell(builder)
        self[3] = Spell(builder)
        self[4] = Spell(builder)
    else
        for i = 1, #serializedSpellBook do
            self[i] = Spell(builder, serializedSpellBook[i])
        end
    end
end

return SpellBook
