local Class = require('class')

local initDir = 3*math.pi/2
local cosInitDir = math.cos(initDir)
local sinInitDir = math.sin(initDir)
local initSpeed1 = 100
local initSpeed2 = 150
local initVX1 = cosInitDir * initSpeed1
local initVX2 = cosInitDir * initSpeed2
local initVY1 = sinInitDir * initSpeed1
local initVY2 = sinInitDir * initSpeed2

local avePointInterval = tileSize/2
local maxWiggle = avePointInterval/3
local reduceMult = 0.999985 --TODO This should get tied into dt.

local FireParticleSystem = Class
{
    name = 'FireParticleSystem',
    function(self, fixture)
        self.fixture = fixture
        self.body = fixture:getBody()
        self.image = love.graphics.newImage("particles/firePart.png")
        self.systems = {}
        self.emRate = 15
        self.speed1 = initSpeed1
        self.speed2 = initSpeed2
        self.pLife = 0.5
        -- Evenly distribute the particle systems within the shape.
        local x1, y1, x2, y2 = fixture:getBoundingBox()
        local i = 1
        for x = x1, x2, avePointInterval do
            for y = y1, y2, avePointInterval do
                if fixture:testPoint(x, y) then
                    local p = love.graphics.newParticleSystem(self.image, 1000)
                    p:setGravity(0, 0)
                    p:setEmissionRate(self.emRate)
                    p:setSpeed(self.speed1, self.speed2)
                    p:setSizes(1, 0.5)
                    p:setColors(220, 105, 20, 255, 194, 30, 18, 0)
                    p:setPosition(0, 0)
                    p:setLifetime(10000)
                    p:setParticleLife(self.pLife)
                    p:setDirection(initDir)
                    p:setSpread(math.pi/8)
                    p:start()
                    self.systems[i] = {}
                    self.systems[i].p = p
                    local adjX = math.random(x - maxWiggle, x + maxWiggle)
                    local adjY = math.random(y - maxWiggle, y + maxWiggle)
                    self.systems[i].xOff, self.systems[i].yOff = 
                    self.body:getLocalPoint(adjX, adjY)
                    i = i + 1
                end
            end
        end
    end
}

function FireParticleSystem:update(dt, vX, vY)
    local newVX1 = initVX1 - vX
    local newVX2 = initVX2 - vX
    local newVY1 = initVY1 - vY
    local newVY2 = initVY2 - vY
    local newSpeed1 = math.sqrt((newVX1*newVX1) + (newVY1*newVY1))
    local newSpeed2 = math.sqrt((newVX2*newVX2) + (newVY2*newVY2))
    local newAngle1 = math.atan2(newVY1, newVX1)
    for i = 1, #self.systems do
        self.systems[i].p:setDirection(newAngle1)
        self.systems[i].p:setSpeed(newSpeed1, newSpeed2)
        self.systems[i].p:update(dt)
    end
end

function FireParticleSystem:reduce(deathTime, deathSeconds)
    --Causes a dying particle system to reduce in intensity.
    local timeRemaining = deathTime - os.clock()
    local percentRemaining = timeRemaining / deathSeconds
    for i = 1, #self.systems do
        self.systems[i].p:setParticleLife(self.pLife*percentRemaining)
    end
end
    
function FireParticleSystem:draw(x, y, angle)
    --love.graphics.setColorMode("modulate")
    --love.graphics.setBlendMode("additive")
    local c = math.cos(angle)
    local s = math.sin(angle)
    for i = 1, #self.systems do
        local sys = self.systems[i]
        local adjX = x + sys.xOff*c - sys.yOff*s
        local adjY = y + sys.xOff*s + sys.yOff*c
        love.graphics.draw(sys.p, adjX, adjY)
    end
end

return FireParticleSystem
