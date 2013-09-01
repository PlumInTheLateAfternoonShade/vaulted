require 'lib.deepcopy.deepcopy'
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
        local t = savedSelf or {points = points, 
        color = color, center = center}
        self.center = t.center
        self.points = {}
        for i = 1, #t.points do
            self.points[i] = Point(t.points[i].x, t.points[i].y)
        end
        self.color = table.deepcopy(t.color)
        self.ambientColor = table.deepcopy(self.color)
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
        self.firstUpdate = false
        local centroid = self:computeCentroid()
        self:centralize(centroid)
        self.body = love.physics.newBody(self.world,
        self.center.x, self.center.y, self.type)
        --This is perhaps the ugliest thing I've ever written.
        --There must be a clever way to do it with unpack.
        --Or maybe a function in Point that returns x, y?
        local a, b, c, d, e, f, g, h = unpack(self.points)
        if h then
            self.shape = love.physics.newPolygonShape(a.x, a.y, 
            b.x, b.y, c.x,
            c.y, d.x, d.y, e.x, e.y, f.x, f.y, g.x, g.y, h.x, h.y)
        elseif g then
            self.shape = love.physics.newPolygonShape(a.x, a.y, 
            b.x, b.y, c.x,
            c.y, d.x, d.y, e.x, e.y, f.x, f.y, g.x, g.y)
        elseif f then
            self.shape = love.physics.newPolygonShape(a.x, a.y, 
            b.x, b.y, c.x,
            c.y, d.x, d.y, e.x, e.y, f.x, f.y)
        elseif e then
            self.shape = love.physics.newPolygonShape(a.x, a.y, 
            b.x, b.y, c.x,
            c.y, d.x, d.y, e.x, e.y)
        elseif d then
            self.shape = love.physics.newPolygonShape(a.x, a.y, 
            b.x, b.y, c.x,
            c.y, d.x, d.y)
        else
            self.shape = love.physics.newPolygonShape(a.x, a.y, 
            b.x, b.y, c.x,
            c.y)
        end
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
    self:updateTemp(dt)
end

function CollidableObject:updateTemp(dt)
    local mult = 0
    local diff = self.temp - self.ambientTemp
    if diff > 0 then
        mult = -1000
    elseif diff < 0 then
        mult = 1000
    end
    self.color.r = limit(self.ambientColor.r + diff, 0, 255)
    self.color.g = limit(self.ambientColor.g + diff/3, 0, 255)
    self.color.b = limit(self.ambientColor.b - diff, 0, 255)
    --print('mult = '..mult)
    --print('temp = '..self.temp..' amTemp = '..self.ambientTemp)
    --print('diff = '..diff..'color = '..tostring(self.color))
    self.temp = self.temp + mult/math.max(self.body:getMass(), 0.1)*dt
end

function CollidableObject:beginCollision(other, contact, world)
    --Update the temp as a weighted average.
    --This should really happen non-instantaneously and when things
    --are near each other, but this is good enough for now.
    if other.type == 'dynamic' and self.type == 'dynamic' then
        local m1 = self.body:getMass()
        local m2 = other.body:getMass()
        self.temp = (self.temp + (m1*self.temp + m2*other.temp)/(m1 + m2))/2
    end
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

function CollidableObject:applyBolt(power, element)

end

function CollidableObject:queueVelocity(v)
    self.queuedVelocity = v
end

function CollidableObject:computeCentroid()
    return computeCentroid(self.points)    
end

function CollidableObject:centralize(c)
    for i = 1, #self.points do
        self.points[i] = self.points[i] - c
    end
end

function CollidableObject:getSpeed()
    local vX, vY = self.body:getLinearVelocity()
    return Point(vX, vY):magnitude()
end

function CollidableObject:getImpact()
    --A hacky way to calculate the "force" of an impact
    --because it doesn't look like there's an easy way
    --to get acceleration.
    return self:getSpeed()*self.body:getMass()
end

return CollidableObject
