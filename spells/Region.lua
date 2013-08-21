require('lib.deepcopy.deepcopy')
local Seg = require('geometry.Seg')
local Point = require('geometry.Point')
local Element = require('spells.Element')
require('spells.effectFactory')

-- Defines a connected region of lines of one element.

local Class = require('HardonCollider.class')
Region = Class
{
    name = 'Region',
    function(self, seedLine)
        self.seed = seedLine
        self.element = eles.getEleFromColor(self.seed.c)
        self.lines = {self.seed}
        self.effect = nil
        self.power = 0
    end
}

function Region:compress()
    -- Compresses a region's lines into 1 to 16.
    self.lines = table.deepcopy(self.lines)
    for i = 1, #self.lines do
        self.lines[i]:compress()
    end
end

function Region:assignPower()
    for i = 1, #self.lines do
        self.power = self.power + self.lines[i]:length()
    end
    return self.power
end

function Region:assignEffect()
    print('#lines: '..#self.lines)
    self.effect = effectFactory:makeEffect(self.lines, self.element, self.power)
end

function Region.__tostring(r)
    str = 'REGION element: '..tostring(r.element)..' | power: '..r.power..'\n'
    for i = 1, #r.lines do
        str = str..tostring(r.lines[i])..'\n'
    end
    str = str..'===========================\n'
    return str
end
