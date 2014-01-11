local temperatureSystem = require('systems.temperatureSystem')

-- Allows an object in the game world with this component to have a dynamic temperature.
local temperature = {}

function temperature.create(id, initTemp)
    local c = {}
    c.id = id
    c.ambientTemp = initTemp
    c.temp = c.ambientTemp
    temperatureSystem:add(c)
    return c
end

return temperature
