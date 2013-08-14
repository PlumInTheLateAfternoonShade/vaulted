-- For casting spells.
local Class = require('HardonCollider.class')
Spell = Class
{
    name = 'Spell',
    function(self, key)
        self.key = key
        self.lines = {}
    end
}

function Spell:cast(num, caster)
    --TODO
    if num == 1 then
        caster.YVeloc = -400
    end
end
