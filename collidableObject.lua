local Class = require 'class'
-- Defines an object in the game world that can be collided with.
-- Just a rectangle for now.
CollidableObject = Class
{
    name = 'CollidableObject',
    function(self, world, point, w, h, friction, type, color)
        self.body = love.physics.newBody(world, point.x, point.y, type)
        self.shape = love.physics.newRectangleShape(w, h)
        self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setFriction(friction)
        self.color = color
    end
}

function CollidableObject:draw()
    setColor(self.color)
    love.graphics.polygon("fill",
                          self.body:getWorldPoints(self.shape:getPoints()))
end


