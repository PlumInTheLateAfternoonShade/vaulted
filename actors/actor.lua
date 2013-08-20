local Class = require 'class'
require 'collidableObject'
-- Defines an object in the game world that moves around independent of impulses.
-- Just a rectangle for now.
Actor = Class
{
    name = 'Actor',
    function(self, world, point, w, h, friction, color)
        CollidableObject.construct(self, world, point, w, h, friction,
                                   "dynamic", color)
    end
}
Actor:inherit(CollidableObject)
