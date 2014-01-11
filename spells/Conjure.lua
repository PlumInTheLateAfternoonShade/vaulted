local Class = require('class')
local Effect = require('spells.Effect')
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
    print('Applying a conjure of '..self.element.name)
    print('Scaled Conjure center apply: '..tostring(self.center))
    local points, center = self:mirrorIfLeftFacing(caster.facingRight)
    objectFactory.createElemental(points, 
    Point(caster.body:getX() + center.x, 
    caster.body:getY() + center.y),
    self.element.name)
end

return Conjure
