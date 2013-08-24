require 'utils'
local Class = require 'class'
local Point = require 'geometry.Point'
-- Defines an object in the game world that can be collided with.
-- Just a rectangle for now.
local CollidableObject = Class
{
    name = 'CollidableObject',
    function(self, world, points, center, friction, type, color, name, 
        savedSelf)
        local table = savedSelf or {points = points, 
        color = color, center = center}
        self.center = table.center
        self.points = {}
        for i = 1, #table.points do
            self.points[i] = Point(table.points[i].x, table.points[i].y)
        end
        self.color = table.color
        self.body = love.physics.newBody(world,
        self.center.x, self.center.y, type)
        local a, b, c, d = unpack(self.points)
        self.shape = love.physics.newPolygonShape(a.x, a.y, b.x, b.y, c.x,
        c.y, d.x, d.y)
        self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setFriction(friction)
        self.fixture:setUserData(name)
    end
}

function CollidableObject:draw()
    setColor(self.color)
    love.graphics.polygon("fill",
                          self.body:getWorldPoints(self.shape:getPoints()))
end

function CollidableObject:update(dt)
    self.center.x, self.center.y = self.body:getWorldCenter()
end

return CollidableObject
