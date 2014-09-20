local experienceSystem = require 'systems.experienceSystem'
local Health = require('components.Health')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles health components.
local HealthSystem = require('lib.middleclass')(
    'HealthSystem', ComponentSystem)

function HealthSystem:init(referenceSystem, entities)
    self.components = entities[Health]
    ComponentSystem.init(self, referenceSystem)
end

local function updateHealth(id, comp, dt)
    local xp = experienceSystem:getXp(id)
    comp.health = math.min(comp.health + xp/20*comp.healthMult*dt, xp*comp.healthMult)
end

function HealthSystem:update(dt)
    for id, comp in pairs(self.components) do updateHealth(id, comp, dt) end
end

function HealthSystem:getHealth(id)
    return self.components[id].health
end

function HealthSystem:getHealthPercent(id)
    return self:getHealth(id) / experienceSystem:getXp(id)
end

local healthSystemInstance = HealthSystem:new()
return healthSystemInstance
