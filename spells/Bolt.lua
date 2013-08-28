local Class = require('class')
local Effect = require('spells.Effect')
local ElementalObject = require('spells.ElementalObject')
local Point = require('geometry.Point')
local Seg = require('geometry.Seg')

-- An effect that casts a bolt of a specific element.
-- Bolts are shorter-range and less powerful than many spells,
-- but they can travel through certain objects (and electrocute water?)
local Bolt = Class
{
    name = 'Bolt',
    function(self, lines, center, element)
        self.name = 'Bolt'
        self.element = element
        self.lines = lines
        self.center = center
    end
}
Bolt:inherit(Effect)

function Bolt:apply(world, caster)
    print('Scaled Bolt center apply: '..tostring(self.center))

end

return Bolt
