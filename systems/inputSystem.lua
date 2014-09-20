local keys = require 'keys'
local walkingSystem = require 'systems.walkingSystem'
local spellBookSystem = require 'systems.spellBookSystem'
local soundSystem = require 'systems.soundSystem'
local Input = require('components.Input')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles position components.
local InputSystem = require('lib.middleclass')(
    'InputSystem', ComponentSystem)

function InputSystem:init(referenceSystem, entities)
    self.components = entities[Input]
    ComponentSystem.init(self, referenceSystem)
end

function InputSystem:update(dt)
    for id, comp in pairs(self.components) do
        if comp.firstUpdate then
            self:syncWithKeys(comp)
            comp.firstUpdate = false
        end
    end
end

function InputSystem:keyPressed(key)
    for id, comp in pairs(self.components) do
        if comp.keyPresses[key] then
            comp.keyPresses[key]()
        end
    end
end

function InputSystem:keyReleased(key)
    for id, comp in pairs(self.components) do
        if comp.keyReleases[key] then
            comp.keyReleases[key]()
        end
    end
end

function InputSystem:syncWithKeys(c)
    c.keyPresses = 
    {
        [keys.right] = function () return walkingSystem:startWalkingRight(c.id) end,
        [keys.left] = function () return walkingSystem:startWalkingLeft(c.id) end,
    }
    if c.canAdministrate then
        c.keyPresses[keys.openMenu] = function ()
            soundSystem:stopMusic()
            return updateState("back to main menu")
        end
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

function InputSystem:syncAllWithKeys()
    if not self.components then return end
    for id, comp in pairs(self.components) do
        self.components[id] = self:syncWithKeys(comp)
    end
end

return InputSystem:new()
