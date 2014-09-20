local experienceSystem = require 'systems.experienceSystem'
local Mana = require('components.Mana')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles mana components.
local ManaSystem = require('lib.middleclass')(
    'ManaSystem', ComponentSystem)

function ManaSystem:init(referenceSystem, entities)
    self.components = entities[Mana]
    ComponentSystem.init(self, referenceSystem)
end

local function updateMana(id, comp, dt)
    local xp = experienceSystem:getXp(id)
    comp.mana = math.min(comp.mana + xp/20*comp.manaMult*dt, xp*comp.manaMult)
end

function ManaSystem:update(dt)
    for id, comp in pairs(self.components) do updateMana(id, comp, dt) end
end

function ManaSystem:deduct(id, amount)
    local comp = self.components[id]
    if comp.mana < amount then return false end
    comp.mana = math.max(0, comp.mana - amount)
    return true
end

function ManaSystem:getMana(id)
    return self.components[id].mana
end

function ManaSystem:getManaPercent(id)
    return self:getMana(id) / experienceSystem:getXp(id)
end

return ManaSystem:new()
