local Class = require 'class'
require 'actors.actor'
require 'geometry.Point'
-- Defines the player character in the game world.
-- Just a rectangle for now.
Hero = Class
{
    name = '',
    function(self, world, point, w, h)
        Actor.construct(self, world, point, w, h, 1, {r=230, g=255, b=255})
        --self.fixture:setDensity(10)
        --self.body:setInertia(10)
        self.body:setAngularDamping(0.1)
        self.body:setLinearDamping(0.1)
        self.fixture:setFriction(1)
    end
}
Hero:inherit(Actor)

