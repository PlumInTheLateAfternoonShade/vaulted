local Class = require('class')
local Effect = require('spells.Effect')
local ElementalObject = require('spells.ElementalObject')
local Point = require('geometry.Point')
local Seg = require('geometry.Seg')

-- An effect that sunmons a polygon physics body of the appropriate element.
local Conjure = Class
{
    name = 'Conjure',
    function(self, points, center, element)
        self.name = 'Conjure'
        self.element = element
        self.points = points
        self.center = center
        --[[self.center:scale(tileSize / 2)
        print('Scaled Conjure center: '..tostring(self.center))
        for i = 1, #self.points do
            self.points[i]:scale(tileSize / 2)
        end]]--
    end
}
Conjure:inherit(Effect)

function Conjure:apply(world, caster)
    print('Applying a conjure of '..self.element.t)
    print('Scaled Conjure center apply: '..tostring(self.center))
    table.insert(objects, ElementalObject(world, self.points,
    Point(caster.body:getX() + self.center.x, 
    caster.body:getY() + self.center.y),
    self.element))
end

return Conjure
