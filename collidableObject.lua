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
        self.firstUpdate = true
        self.world = world
        self.name = name
        self.friction = friction
        self.type = type
        self.expireTime = 0
        self.queuedVelocity = nil
        self.ambientTemp = 300
        self.temp = self.ambientTemp
    end
}

function CollidableObject:draw()
    setColor(self.color)
    love.graphics.polygon("fill",
                          self.body:getWorldPoints(self.shape:getPoints()))

end

function CollidableObject:update(dt)
    if self.firstUpdate then
        --Need to construct here rather than constructor,
        --in case construct occurs during middle of physics calcs.
        --TODO subclasses need to do this too!
        self.firstUpdate = false
        self.body = love.physics.newBody(self.world,
        self.center.x, self.center.y, self.type)
        local a, b, c, d = unpack(self.points)
        --[[b = b - a
        c = c - a
        d = d - a
        a = Point(0, 0)]]--
        --self.shape = love.physics.newPolygonShape(a.x, a.y, b.x, b.y, c.x,
        --c.y, d.x, d.y) TODO
        self.shape = love.physics.newRectangleShape(math.abs(a.x - c.x),
        math.abs(a.y - c.y))
        self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setFriction(self.friction)
        self.fixture:setUserData(self.name)
    end
    if self.queuedVelocity then
        self.body:setLinearVelocity(
        self.queuedVelocity.x, self.queuedVelocity.y)
        self.queuedVelocity = nil
    end
    self.center.x, self.center.y = self.body:getWorldCenter()
    self:deleteIfNecessary()
end

function CollidableObject:beginCollision(other, contact, world)
    --Update the temp as the weighted average. 
end

function CollidableObject:endCollision(other, contact, world)
    --Do nothing special.
end

function CollidableObject:deleteIfNecessary()
    if self.expireTime ~= 0 and os.clock() > self.expireTime then
        self:destroy()
    end
end

function CollidableObject:setDeleteTime(expireSeconds)
    if self.expireTime == 0 then
        self.expireTime = os.clock() + expireSeconds
    end
end

function CollidableObject:destroy()
    --TODO: should I pass in i to constructor?
    --Maybe a table of fixture:CollidableObjects would be better.
    for i = 1, #objects do
        if objects[i].fixture == self.fixture then
            self.fixture:destroy()
            table.remove(objects, i)
            return
        end
    end
end

function CollidableObject:queueVelocity(v)
    self.queuedVelocity = v
end

return CollidableObject
