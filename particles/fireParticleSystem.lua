local Class = require('class')
local FireImage = require('images.spells.FireImage')

local initDir = 3*math.pi/2
local cosInitDir = math.cos(initDir)
local sinInitDir = math.sin(initDir)
local initSpeed1 = 100
local initSpeed2 = 150
local initVX1 = cosInitDir * initSpeed1
local initVX2 = cosInitDir * initSpeed2
local initVY1 = sinInitDir * initSpeed1
local initVY2 = sinInitDir * initSpeed2

local FireParticleSystem = Class
{
    name = 'FireParticleSystem',
    function(self, fixture, points, center)
        self.points = points
        self.fixture = fixture
        self.body = fixture:getBody()
        self.center = center
        local fireImage = FireImage(points, center)
        self.image = fireImage.image
        self.emRate = 15
        self.speed1 = initSpeed1
        self.speed2 = initSpeed2
        self.pLife = 0.5
        local p = love.graphics.newParticleSystem(self.image, 1000)
        p:setGravity(0, 0)
        p:setEmissionRate(self.emRate)
        p:setSpeed(self.speed1, self.speed2)
        p:setColors(220, 105, 20, 255, 194, 30, 18, 0)
        p:setPosition(0, 0)
        p:setLifetime(10000)
        p:setParticleLife(self.pLife)
        p:setDirection(initDir)
        p:setSpread(math.pi/8)
        p:start()
        self.p = p
        --TODO
        --self.xOff = 0--1*fireImage.left
        --self.yOff = 0--1*fireImage.top
    end
}

function FireParticleSystem:update(dt, vX, vY, color)
    local newVX1 = initVX1 - vX
    local newVX2 = initVX2 - vX
    local newVY1 = initVY1 - vY
    local newVY2 = initVY2 - vY
    local newSpeed1 = math.sqrt((newVX1*newVX1) + (newVY1*newVY1))
    local newSpeed2 = math.sqrt((newVX2*newVX2) + (newVY2*newVY2))
    local newAngle1 = math.atan2(newVY1, newVX1)
    self.p:setDirection(newAngle1)
    self.p:setSpeed(newSpeed1, newSpeed2)
    self.p:setColors(color.r, color.g, color.b, 255, 
    color.r, color.g, color.b, 0)
    self.p:update(dt)
end

function FireParticleSystem:reduce(deathTime, deathSeconds)
    --Causes a dying particle system to reduce in intensity.
    local timeRemaining = deathTime - os.clock()
    local percentRemaining = timeRemaining / deathSeconds
    self.p:setParticleLife(self.pLife*percentRemaining)
end
    
function FireParticleSystem:draw(x, y, angle)
    love.graphics.setBlendMode("additive")
    --[[local c = math.cos(angle)
    local s = math.sin(angle)
    local adjX = x + self.xOff*c - self.yOff*s
    local adjY = y + self.xOff*s + self.yOff*c]]--
    love.graphics.draw(self.p, x, y, angle)
    love.graphics.setBlendMode("alpha")
end

return FireParticleSystem
