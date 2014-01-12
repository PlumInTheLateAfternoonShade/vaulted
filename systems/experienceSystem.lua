local positionSystem = require 'systems.positionSystem'

-- Handles experience components.
local experienceSystem = {}

require('systems.componentSystem'):inherit(experienceSystem)

local function updateExperience(id, comp, dt)
    --XP is simply the farthest an actor has gone in the world.
    comp.farthestX = math.max(positionSystem:getCenter(id).x, comp.farthestX)
    comp.xp = comp.farthestX / worldXEnd * comp.xpMult + comp.xpOffset
end

function experienceSystem:update(dt)
    for id, comp in pairs(self.components) do updateExperience(id, comp, dt) end
end

function experienceSystem:getXp(id)
    return self.components[id].xp
end

return experienceSystem
