require 'utils'
local Class = require 'class'
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local CollidableObject = require 'collidableObject'
local FireParticleSystem = require 'particles.fireParticleSystem'
local deathSeconds = 0.3 --TODO: In tens of seconds for some reason?
-- Defines an object in the game world that is a specific element.
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
        self.maxMassToBreak = element.density*4
        self.ambientTemp = element.temp
        self.temp = self.ambientTemp
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
            self.particle = FireParticleSystem(self.fixture, self.color)
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
            self.particle:update(self.partUpdateCounter, vX, vY, self.color)
            self.partUpdateCounter = 0
        end
    end
end

function ElementalObject:beginCollision(other, contact, world)
    --TODO: Separate elements into 4 classes? Kind of annoying.
    if self.element.t == 'fire' or self.element.t == 'water' then
        local deleteSeconds = nil
        if self.body:getMass() > self.maxMassToBreak then
            local numNew = math.random(2, 4)
            local xb1, yb1, xb2, yb2 = self.fixture:getBoundingBox()
            local vX, vY = self.body:getLinearVelocity() 
            for i = 1, numNew do
                local newCenter =
                Point(math.random(xb1*0.5, xb2*0.5),
                math.random(yb1*0.5, yb2*0.5))
                print('x bco: '..tostring(self.body:getX() - newCenter.x))
                local newPoints = coordsToPoints(self.shape:getPoints())
                local scaleFactor = math.sqrt(1/numNew)
                for j = 1, #newPoints do
                    newPoints[j]:scale(scaleFactor)
                end
                local newObj = ElementalObject(world, 
                newPoints, newCenter, self.element)
                --TODO should take into account other's veloc too.
                local speed = Point(vX, vY):magnitude()
                local newV = Seg(self.center, newCenter):normalize()
                newV:scale(speed)
                newObj:queueVelocity(newV)
                table.insert(objects, newObj)
                if self.element.t == 'fire' then
                    deleteSeconds = 0
                end
            end
            self:setDeleteTime(0)
        elseif self.element.t == 'fire' then
            deleteSeconds = deathSeconds
        end
        if deleteSeconds then
            print('Deleting in '..deleteSeconds..'.')
            self:setDeleteTime(deleteSeconds)
        end
    end
    CollidableObject.beginCollision(self, other, contact, world)
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
