local Class = require('class')

-- Basic superclass for the effect a region has on the world.
local Effect = Class
{
    name = 'Effect',
    function(self)
        self.name = 'Effect'
    end
}

return Effect
