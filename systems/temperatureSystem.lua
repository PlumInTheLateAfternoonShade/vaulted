local physicsSystem = require('systems.physicsSystem')

-- Handles temperature components.
local temperatureSystem = {}

require('systems.componentSystem'):inherit(temperatureSystem)

local function updateTemp(comp, dt)
    local mult = 0
    local diff = comp.temp - comp.ambientTemp
    if diff > 0 then
        mult = -1000
    elseif diff < 0 then
        mult = 1000
    end
    comp.temp = comp.temp + mult/math.max(physicsSystem:getMass(comp.id), 0.1)*dt
    if comp.temp ~= comp.ambientTemp then print('temp to: '..comp.temp) end
end


function temperatureSystem:update(dt)
    for id, comp in pairs(self.components) do updateTemp(comp, dt) end
end

function temperatureSystem:getAdjustedColor(id, ambientColor)
    if not self.components[id] then return ambientColor end
    local diff = self.components[id].temp - self.components[id].ambientTemp
    if diff ~= 0 then print('diff: '..diff) end
    return 
    {
        r = limit(ambientColor.r + diff, 0, 255),
        g = limit(ambientColor.g + diff/3, 0, 255),
        b = limit(ambientColor.b - diff, 0, 255),
        a = ambientColor.a
    }
end

function temperatureSystem:getTemp(id)
    return self.components[id].temp
end

function temperatureSystem:beginCollision(id, otherId, contact)
    --Update the temp as a weighted average.
    --This should really happen non-instantaneously and when things
    --are near each other, but this is good enough for now.
    local tempComp = self:get(id)
    local otherTempComp = self:get(otherId)
    if not tempComp or not otherTempComp then return end
    local mass = physicsSystem:getMass(id)
    local otherMass = physicsSystem:getMass(otherId)
    tempComp.temp = (tempComp.temp + (mass*tempComp.temp + otherMass*otherTempComp.temp)/(mass + otherMass))/2
    print('new temp: '..tempComp.temp..' ambient: '..tempComp.ambientTemp)
end

function temperatureSystem:endCollision(id, otherId, contact)
    --Do nothing special.
end

return temperatureSystem
