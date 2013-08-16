require('Seg')
require('Point')
require('Element')

-- Defines a connected region of lines of one element.

local Class = require('HardonCollider.class')
Region = Class
{
    name = 'Region',
    function(self, seedLine)
        self.seed = seedLine
        self.element = eles.getEleFromColor(self.seed.c)
        self.lines = {self.seed}
        self.type = 'Projectile'
    end
}

function Region:compress()
    -- Compresses a region's lines into 1 to 16.
    for i = 1, #self.lines do
        self.lines[i]:compress()
    end
end

function Region.__tostring(r)
    str = 'REGION element: '..tostring(r.element)..' type: '..r.type..'\n'
    for i = 1, #r.lines do
        str = str..tostring(r.lines[i])..'\n'
    end
    str = str..'===========================\n'
    return str
end
