local Class = require('class')
local Effect = require('spells.Effect')
local ElementalObject = require('spells.ElementalObject')
local Point = require('geometry.Point')
local Seg = require('geometry.Seg')
local objectFactory = require 'systems.objectFactory'

-- An effect that sunmons a polygon physics body of the appropriate element.
local Conjure = Class
{
    name = 'Conjure',
    function(self, points, center, element)
        self.name = 'Conjure'
        self.element = element
        self.points = points
        self.center = center
    end
}
Conjure:inherit(Effect)

function Conjure:apply(world, caster)
    print('Applying a conjure of '..self.element.t)
    print('Scaled Conjure center apply: '..tostring(self.center))
    local points, center = self:mirrorIfLeftFacing(caster.facingRight)
    if self.element.t == 'water' then self.element.t = 'ice' end -- TODO Delete
    if self.element.t == 'earth' or self.element.t == 'air' or self.element.t == 'ice' then
        objectFactory.createElemental(points, 
        Point(caster.body:getX() + center.x, 
        caster.body:getY() + center.y),
        self.element.t)
    else
        table.insert(objects, ElementalObject(world, points,
        Point(caster.body:getX() + center.x, 
        caster.body:getY() + center.y),
        self.element))
    end
end

return Conjure
