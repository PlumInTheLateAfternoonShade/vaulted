require('lib.deepcopy.deepcopy')
local Seg = require('geometry.Seg')
local Point = require('geometry.Point')
local Element = require('spells.Element')
require('spells.effectFactory')
local Class = require('class')

-- Defines a connected region of lines of one element.
local Region = Class
{
    name = 'Region',
    function(self, seedLine, table)
        if table ~= nil then
            print('Making region from file, #lines = '..#table.lines)
            self.seed = Seg(nil, nil, nil, table.seed)
            self.lines = {}
            self.element = table.element
            for i = 1, #table.lines do
                self.lines[i] = Seg(nil, nil, nil, table.lines[i])
            end
            self.power = table.power
            self.effect = effectFactory:makeEffect(self.lines, self.element,
            self.power)
        else
            print('Making new region. Element = '..seedLine.c.r)
            self.seed = seedLine
            self.element = eles.getEleFromColor(self.seed.c)
            print('Element chosen was '..self.element.t)
            self.lines = {self.seed}
            self.effect = nil
            self.power = 0
        end
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

return Region
