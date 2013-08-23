require 'utils'
local Class = require 'class'
local Point = require 'geometry.Point'
-- Defines an object in the game world that can be collided with.
-- Just a rectangle for now.
local CollidableObject = Class
{
    name = 'CollidableObject',
    function(self, world, point, w, h, friction, type, color, name, savedSelf)
        print('Constructing colObj. savedSelf='..tostring(savedSelf))
        local table = savedSelf or {point = point, color = color}
        print('Constructing colObj. color.r='..tostring(color.r))
        self.point = Point(0, 0, table.point)
        print('Constructing colObj. table.color.r='..tostring(table.color.r))
        self.color = table.color
        print('Constructing colObj. self.color.r='..tostring(self.color.r))
        self.body = love.physics.newBody(world,
        self.point.x, self.point.y, type)
        self.shape = love.physics.newRectangleShape(w, h)
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
    self.point.x, self.point.y = self.body:getWorldCenter()
end

return CollidableObject
