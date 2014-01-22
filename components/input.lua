local keys = require 'keys'
local inputSystem = require('systems.inputSystem')

-- Allows an object in the game world with this component to have a dynamic input.
local input = {}

function input.prototype(canAdministrate, canCast)
        
    if canAdministrate == nil then
        canAdministrate = true
    end
    if canCast == nil then
        canCast = true
    end
    return inputSystem:syncWithKeys(
    {
        name = "input",
        canAdministrate = canAdministrate,
        canCast = canCast,
        addToSystems = function (self, id)
            self.id = id
            inputSystem:add(self)
        end
    })
end

function input.create(id, ...)
    local c = input.prototype(...)
    c:addToSystems(id)
    return c
end

return input
