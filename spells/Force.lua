local Class = require('HardonCollider.class')
require('spells.Effect')

-- An effect that imparts a force on objects it encounters.
Force = Class
{
    name = 'Force',
    function(self)
    end
}
Force:inherits(Effect)
