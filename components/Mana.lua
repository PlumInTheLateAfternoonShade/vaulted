-- Allows an object in the game world with this component to cast spells from a pool of mana.
local Mana = require 'lib.middleclass'('Mana',
                 require 'components.Component')

function Mana:initialize(initMana, manaMult)
    self.mana = initMana or 0
    self.manaMult = manaMult or 1
end

return Mana
