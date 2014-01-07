local Class = require('class')
require('utils')
local Point = require('geometry.Point')

local minShakeImpact = 50000 --30000
local maxShakeImpact = 5000000--300000
local shakeDecayRate = 0.4
local shakeMult = 1000

local Camera = Class
{
    name = 'Camera',
    function(self)
        self.x = 0
        self.y = 0
        self.scaleX = 1
        self.scaleY = 1
        self.shakeFactor = 0
        self.shakeXOffset = 0
        self.shakeYOffset = 0
    end
}

function Camera:setAdjPosition(x, y, dt)
    self.x = x - conf.screenWidth/(2*self.scaleX)
    self.y = y - conf.screenHeight/(2*self.scaleY)
    if self.shakeFactor == 0 then
        -- Short circuit to prevent needless computations.
        return
    end
    self.x = self.x + 
    shakeMult*(math.random()-0.5)*self.shakeFactor
    self.y = self.y +
    shakeMult*(math.random()-0.5)*self.shakeFactor
    self.shakeFactor = math.max(self.shakeFactor - shakeDecayRate*dt, 0)
end

function Camera:set()
    love.graphics.push()
    love.graphics.scale(self.scaleX, self.scaleY)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
    love.graphics.pop()
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:rotate(dr)
    self.rotation = self.rotation + dr
end

function Camera:scale(sx, sy)
    self.scaleX = self.scaleX * sx
    self.scaleY = self.scaleY * sy
end

function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function Camera:setScale(sx, sy)
    self.scaleX = sx
    self.scaleY = sy
end

function Camera:shake(a, b, contact)
    -- Begin a camera shake if the contact force is great enough
    if not conf.ShouldCameraShake then
        return
    end
    -- This is a bit of an unscientific hack. Might be able to get
    -- better perf by getting rid of the sqrt computations.
    local aVX, aVY = a:getLinearVelocity()
    local bVX, bVY = b:getLinearVelocity()
    local aS = math.sqrt(aVX*aVX + aVY*aVY)
    local bS = math.sqrt(bVX*bVX + bVY*bVY)
    local impact = (aS*a:getMass() + bS*b:getMass())
    self.shakeFactor = math.max(self.shakeFactor, limit(
    (impact - minShakeImpact)/(maxShakeImpact - minShakeImpact), 0, 1))
end

return Camera
