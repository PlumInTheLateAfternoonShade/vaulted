local experienceSystem = require 'systems.experienceSystem'

-- Handles mana components.
local manaSystem = {}

require('systems.componentSystem'):inherit(manaSystem)

local function updateMana(id, comp, dt)
    local xp = experienceSystem:getXp(id)
    comp.mana = math.min(comp.mana + xp/20*comp.manaMult*dt, xp*comp.manaMult)
end

function manaSystem:update(dt)
    for id, comp in pairs(self.components) do updateMana(id, comp, dt) end
end

function manaSystem:deduct(id, amount)
    local comp = self.components[id]
    if comp.mana < amount then return false end
    comp.mana = math.max(0, comp.mana - amount)
    return true
end

function manaSystem:getMana(id)
    return self.components[id].mana
end

function manaSystem:getManaPercent(id)
    return self:getMana(id) / experienceSystem:getXp(id)
end

return manaSystem
