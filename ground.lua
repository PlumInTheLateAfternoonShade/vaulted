require 'utils'
local Class = require 'class'
local Point = require 'geometry.Point'
local CollidableObject = require 'collidableObject'
-- Defines a piece of the ground in the game world that can be collided with.
-- Just a rectangle for now.
local Ground = Class
{
    name = 'Ground',
    function(self, world, points, center, color)
        CollidableObject.construct(self, world, points, center, 0.5, 'static', 
        color, 'Ground')
    end
}
Ground:inherit(CollidableObject)

return Ground
