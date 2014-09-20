local positionSystem = require 'systems.positionSystem'
local Experience = require('components.Experience')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles position components.
local ExperienceSystem = require('lib.middleclass')(
    'ExperienceSystem', ComponentSystem)

function ExperienceSystem:init(referenceSystem, entities)
    self.components = entities[Experience]
    ComponentSystem.init(self, referenceSystem)
end

local function updateExperience(id, comp, dt)
    --XP is simply the farthest an actor has gone in the world.
    comp.farthestX = math.max(positionSystem:getCenter(id).x, comp.farthestX)
    comp.xp = comp.farthestX / conf.worldXEnd * comp.xpMult + comp.xpOffset
end

function ExperienceSystem:update(dt)
    for id, comp in pairs(self.components) do updateExperience(id, comp, dt) end
end

function ExperienceSystem:getXp(id)
    return self.components[id].xp
end

local experienceSystemInstance = ExperienceSystem:new()
return experienceSystemInstance
