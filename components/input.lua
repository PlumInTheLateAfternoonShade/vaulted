local force = require('components.force') -- TODO delete
local inputSystem = require('systems.inputSystem')
local walkingSystem = require('systems.walkingSystem')
local spellBookSystem = require('systems.spellBookSystem')

-- Allows an object in the game world with this component to have a dynamic input.
local input = {}

function input.create(id)
    local c = {}
    c.id = id
    c.keyPresses = 
    {
        [right] = function () return walkingSystem:startWalkingRight(id) end,
        [left] = function () return walkingSystem:startWalkingLeft(id) end,
        [openMenu] = function () return updateState("back to main menu") end,
        [gesture] = function () return updateState("gestures") end,
        [spell1] = function () return spellBookSystem:cast(id, 1) end,
        [spell2] = function () return spellBookSystem:cast(id, 2) end,
        [spell3] = function () return spellBookSystem:cast(id, 3) end,
        [spell4] = function () return spellBookSystem:cast(id, 4) end,
    }
    c.keyReleases = 
    {
        [right] = function () return walkingSystem:stopWalkingRight(id) end,
        [left] = function () return walkingSystem:stopWalkingLeft(id) end,
    }
    inputSystem:add(c)
    return c
end

return input
