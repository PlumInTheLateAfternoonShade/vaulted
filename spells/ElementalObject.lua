require 'utils'
local Class = require 'class'
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local CollidableObject = require 'collidableObject'
local FireParticleSystem = require 'particles.fireParticleSystem'
local maxMassToBreak = 10 --2.7 --TODO: Should calc based on density of element.
local deathSeconds = 0.3 --TODO: In tens of seconds for some reason?
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
        self.eleObjFirstUpdate = true
        self.partUpdateCounter = 1000
    end
}
ElementalObject:inherit(CollidableObject)

function ElementalObject:draw()
    setColor(self.color)
    if self.particle then
        self.particle:draw(self.body:getX(), self.body:getY(), 
        self.body:getAngle())
    else
        love.graphics.polygon("fill",
        self.body:getWorldPoints(self.shape:getPoints()))
    end
end

function ElementalObject:update(dt)
    CollidableObject.update(self, dt)
    if self.eleObjFirstUpdate then
        self.fixture:setDensity(self.element.density)
        self.body:setGravityScale(self.element.gravScale)
        self.body:resetMassData()
        if self.element.t == 'fire' then
            self.particle = FireParticleSystem(self.fixture)
        end
        self.eleObjFirstUpdate = false
    end
    if self.particle then
        self.partUpdateCounter = self.partUpdateCounter + dt
        if self.partUpdateCounter >= dt*3 then
            local vX, vY = self.body:getLinearVelocity()
            if self.expireTime ~= 0 then
                self.particle:reduce(self.expireTime, deathSeconds)
            end
            self.particle:update(self.partUpdateCounter, vX, vY)
            self.partUpdateCounter = 0
        end
    end
end

function ElementalObject:beginCollision(other, contact, world)
    --TODO: Separate elements into 4 classes? Kind of annoying.
    if self.element.t == 'fire' then
        if self.body:getMass() > maxMassToBreak then
            local numNew = math.random(2, 4)
            for i = 1, numNew do
                local xb1, yb1, xb2, yb2 = self.fixture:getBoundingBox()
                local newCenter = Point(math.random(xb1, xb2),
                math.random(yb1, yb2))

                local newPoints = coordsToPoints(self.shape:getPoints())
                for j = 1, #newPoints do
                    newPoints[j]:scale(1/numNew)
                end
                local newFire = ElementalObject(world, 
                newPoints, newCenter, self.element)
                local vX, vY = self.body:getLinearVelocity() 
                --TODO should take into account other's veloc too.
                local speed = Seg(Point(0, 0), Point(vX, vY)):length()
                local newV = Seg(self.center, newCenter):normalize()
                newV:scale(speed)
                newFire:queueVelocity(newV)
                table.insert(objects, newFire)
            end
            self:setDeleteTime(0)
        else
            self:setDeleteTime(deathSeconds)
        end
    end
end

function coordsToPoints(...)
    local num = select('#', ...)
    local points = {}
    for i = 1, num, 2 do
        local x = select(i, ...)
        local y = select(i + 1, ...)
        table.insert(points, Point(x, y))
    end
    return points
end

function ElementalObject:endCollision(other, contact, world)

end

return ElementalObject
