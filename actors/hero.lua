local Class = require 'class'
local Actor = require 'actors.actor'
require 'geometry.Point'
local SpellBook = require 'spellBook'
-- Defines the player character in the game world.
-- Just a rectangle for now.

local defaultHero = 
{
    spellBook = nil
}

local Hero = Class
{
    name = 'Hero',
    function(self, world, point, w, h, savedSelf)
        Actor.construct(self, world, point, w, h, 1, {r=230, g=255, b=255},
        savedSelf)
        self.name = 'Hero'
        local table = savedSelf or defaultHero
        self.spellBook = SpellBook(table.spellBook)
        --self.fixture:setDensity(10)
        --self.body:setInertia(10)
        self.body:setAngularDamping(0.1)
        self.body:setLinearDamping(0.1)
        self.fixture:setFriction(1)
    end
}
Hero:inherit(Actor)

return Hero
