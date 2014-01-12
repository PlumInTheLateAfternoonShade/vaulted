local inputSystem = require('systems.inputSystem')
local walkingSystem = require('systems.walkingSystem')

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
