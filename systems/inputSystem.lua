local keys = require 'keys'
local walkingSystem = require 'systems.walkingSystem'
local spellBookSystem = require 'systems.spellBookSystem'

-- Handles input components.
local inputSystem = {}

require('systems.componentSystem'):inherit(inputSystem)

function inputSystem:keyPressed(key)
    for id, comp in pairs(self.components) do
        if comp.keyPresses[key] then
            comp.keyPresses[key]()
        end
    end
end

function inputSystem:keyReleased(key)
    for id, comp in pairs(self.components) do
        if comp.keyReleases[key] then
            comp.keyReleases[key]()
        end
    end
end

function inputSystem:syncWithKeys(c)
    c.keyPresses = 
    {
        [keys.right] = function () return walkingSystem:startWalkingRight(c.id) end,
        [keys.left] = function () return walkingSystem:startWalkingLeft(c.id) end,
    }
    if c.canAdministrate then
        c.keyPresses[keys.openMenu] = function () return updateState("back to main menu") end
        c.keyPresses[keys.gesture] = function () return updateState("gestures") end
    end
    if c.canCast then
        for i, key in ipairs(keys.spells) do
            c.keyPresses[key] = function () return spellBookSystem:cast(c.id, i) end
        end
    end
    c.keyReleases = 
    {
        [keys.right] = function () return walkingSystem:stopWalkingRight(c.id) end,
        [keys.left] = function () return walkingSystem:stopWalkingLeft(c.id) end,
    }
    return c
end

function inputSystem:syncAllWithKeys()
    if not self.components then return end
    for id, comp in pairs(self.components) do
        self.components[id] = self:syncWithKeys(comp)
    end
end

return inputSystem
