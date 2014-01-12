local experienceSystem = require 'systems.experienceSystem'

-- Handles health components.
local healthSystem = {}

require('systems.componentSystem'):inherit(healthSystem)

local function updateHealth(id, comp, dt)
    local xp = experienceSystem:getXp(id)
    comp.health = math.min(comp.health + xp/20*comp.healthMult*dt, xp*comp.healthMult)
end

function healthSystem:update(dt)
    for id, comp in pairs(self.components) do updateHealth(id, comp, dt) end
end

function healthSystem:getHealth(id)
    return self.components[id].health
end

function healthSystem:getHealthPercent(id)
    return self:getHealth(id) / experienceSystem:getXp(id)
end

return healthSystem
