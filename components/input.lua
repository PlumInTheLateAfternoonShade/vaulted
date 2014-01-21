local keys = require 'keys'
local inputSystem = require('systems.inputSystem')
local walkingSystem = require('systems.walkingSystem')
local spellBookSystem = require('systems.spellBookSystem')

-- Allows an object in the game world with this component to have a dynamic input.
local input = {}

function input.syncWithKeys(c)
    local id = c.id
    c.keyPresses = 
    {
        [keys.right] = function () return walkingSystem:startWalkingRight(id) end,
        [keys.left] = function () return walkingSystem:startWalkingLeft(id) end,
        [keys.openMenu] = function () return updateState("back to main menu") end,
        [keys.gesture] = function () return updateState("gestures") end,
    }
    for i, key in ipairs(keys.spells) do
        c.keyPresses[key] = function () return spellBookSystem:cast(id, i) end
    end
    c.keyReleases = 
    {
        [keys.right] = function () return walkingSystem:stopWalkingRight(id) end,
        [keys.left] = function () return walkingSystem:stopWalkingLeft(id) end,
    }
    return c
end

function input.create(id)
    local c = {}
    c.id = id
    c = input.syncWithKeys(c)
    inputSystem:add(c)
    return c
end

return input
