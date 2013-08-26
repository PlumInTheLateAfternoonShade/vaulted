local Class = require 'class'
local CollidableObject = require 'collidableObject'
local Element = require 'spells.Element'
local maxAngVToRight = 30
local maxVertVToRight = 2000
-- Defines an object in the game world that moves around 
-- independent of impulses.
-- Just a rectangle for now.
-- TODO: Look into changing the rotational inertia to make it less wobbly.
local Actor = Class
{
    name = 'Actor',
    function(self, world, points, center, friction, color, savedSelf)
        CollidableObject.construct(self, world, points, center, friction,
        "dynamic", color, "Actor", savedSelf)
        self.standupAccel = -250
        self.walkingForce = 0
        self.maxWalkingForce = 0
        self.righting = false
        self.actorFirstUpdate = true
        self.isCollided = false
        self.ambientTemp = 310.15
        self.temp = self.ambientTemp
    end
}
Actor:inherit(CollidableObject)

-- Makes the actor try to stand up.
function Actor:rightSelf(dt)
    if self.righting then
        self.body:setAngle(0)
        self.body:setAngularVelocity(0)
        --[[local angle = self:getWrappedAngle()
        if angle == 0 then
            self.righting = false
        else
            --local v = self.body:getAngularVelocity()
            local v = self.standupAccel*angle*dt
            self.body:setAngularVelocity(v)
            if math.abs(v) < 10 then
                print(string.format("%.2f", v).."..."..
                string.format("%.2f", self.body:getAngularVelocity()))
            end
        end]]--
    end
end

function Actor:setWalkingLeft()
    self.walkingForce = -1 * self.maxWalkingForce
end

function Actor:setWalkingRight()
    self.walkingForce = self.maxWalkingForce
end

function Actor:setStanding()
    self.walkingForce = 0
end

function Actor:isWalkingLeft()
    return (self.walkingForce < 0)
end

function Actor:isWalkingRight()
    return (self.walkingForce > 0)
end

function Actor:isStanding()
    return (self.walkingForce == 0)
end

function Actor:walk(dt)
    self.body:applyForce(self.walkingForce, 0)
end

function Actor:update(dt)
    CollidableObject.update(self, dt)
    if self.actorFirstUpdate then
        self.fixture:setDensity(water.density)
        self.body:resetMassData()
        self.maxWalkingForce = self.body:getMass()*2500
        self.actorFirstUpdate = false
    end
    local vX, vY = self.body:getLinearVelocity()
    local angV = self.body:getAngularVelocity()
    if math.abs(vY) < maxVertVToRight 
    and math.abs(angV) < maxAngVToRight 
    and self.isCollided then
        self:setRighting(true)
    else
        self:setRighting(false)
    end
    self:rightSelf(dt)
    self:walk(dt)
end

function Actor:setRighting(value)
    self.righting = value
    self.body:setFixedRotation(value)
end

function Actor:getWrappedAngle()
    local angle = (self.body:getAngle() % (math.pi * 2))
    if angle > math.pi then
        angle = angle - 2 * math.pi
    end 
    return angle
end

function Actor:beginCollision(other, contact, world)
    -- TODO: should damage based on velocity of contact
    self.isCollided = true
    CollidableObject.beginCollision(self, other, contact, world)
end


function Actor:endCollision(other, contact, world)
    self.isCollided = false
end

return Actor
