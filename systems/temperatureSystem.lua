local physicsSystem = require('systems.physicsSystem')
local Temperature = require('components.Temperature')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles Temperature components.
local TemperatureSystem = require('lib.middleclass')(
    'TemperatureSystem', ComponentSystem)

function TemperatureSystem:init(referenceSystem, entities)
    self.components = entities[Temperature]
    ComponentSystem.init(self, referenceSystem)
end

local function updateTemp(comp, dt)
    local mult = 0
    local diff = comp.temp - comp.ambientTemp
    if diff > 0 then
        mult = -1000
    elseif diff < 0 then
        mult = 1000
    end
    comp.temp = comp.temp + mult/math.max(physicsSystem:getMass(comp.id), 0.1)*dt
end

function TemperatureSystem:update(dt)
    for id, comp in pairs(self.components) do updateTemp(comp, dt) end
end

function TemperatureSystem:getAdjustedColor(id, ambientColor)
    if not self.components[id] then return ambientColor end
    local diff = self.components[id].temp - self.components[id].ambientTemp
    return 
    {
        r = limit(ambientColor.r + diff, 0, 255),
        g = limit(ambientColor.g + diff/3, 0, 255),
        b = limit(ambientColor.b - diff, 0, 255),
        a = ambientColor.a
    }
end

function TemperatureSystem:getTemp(id)
    return self.components[id].temp
end

function TemperatureSystem:beginCollision(id, otherId, contact)
    --Update the temp as a weighted average.
    --This should really happen non-instantaneously and when things
    --are near each other, but this is good enough for now.
    local tempComp = self:get(id)
    local otherTempComp = self:get(otherId)
    if not tempComp or not otherTempComp then return end
    local mass = physicsSystem:getMass(id)
    local otherMass = physicsSystem:getMass(otherId)
    tempComp.temp = (tempComp.temp + (mass*tempComp.temp + otherMass*otherTempComp.temp)/(mass + otherMass))/2
end

function TemperatureSystem:endCollision(id, otherId, contact)
    --Do nothing special.
end

local temperatureSystemInstance = TemperatureSystem:new()
return temperatureSystemInstance
