local temperatureSystem = require('systems.temperatureSystem')

-- Allows an object in the game world with this component to have a dynamic temperature.
local temperature = {}

function temperature.prototype(initTemp)
    local c = {}
    c.ambientTemp = initTemp
    c.temp = c.ambientTemp
    function c:addToSystems(id)
        self.id = id
        temperatureSystem:add(self)
    end
    return c
end

function temperature.create(id, initTemp)
    local c = temperature.prototype(initTemp)
    c:addToSystems(id)
    return c
end

return temperature
