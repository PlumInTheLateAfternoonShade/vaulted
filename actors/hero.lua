local Class = require 'class'
local Actor = require 'actors.actor'
local Point = require 'geometry.Point'
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
    function(self, world, points, center, savedSelf)
        --Set default hero start position
        if points == nil and savedSelf == nil then
            points = 
            {
                Point(0, 0),
                Point(0, tileSize*3),
                Point(tileSize, tileSize*3),
                Point(tileSize, 0)
            }
        end
        Actor.construct(self, world, points, center, 1, {r=230, g=255, b=255},
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
