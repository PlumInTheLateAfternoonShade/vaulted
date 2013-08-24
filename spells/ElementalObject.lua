require 'utils'
local Class = require 'class'
local Point = require 'geometry.Point'
local CollidableObject = require 'collidableObject'
-- Defines an object in the game world that can be collided with.
-- Just a rectangle for now.
local ElementalObject = Class
{
    name = 'ElementalObject',
    function(self, world, points, center, element)
        local name = element.t..'Object'
        self.element = element
        CollidableObject.construct(self, world, points, center, 
        element.friction, 'dynamic', element.c, name)
        self.fixture:setDensity(element.density)
        self.body:resetMassData()
    end
}
ElementalObject:inherit(CollidableObject)

function ElementalObject:draw()
    setColor(self.color)
    love.graphics.polygon("fill",
                          self.body:getWorldPoints(self.shape:getPoints()))
end

function ElementalObject:update(dt)
    self.center.x, self.center.y = self.body:getWorldCenter()
end

return ElementalObject
