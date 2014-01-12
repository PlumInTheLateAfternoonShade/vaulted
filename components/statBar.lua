local graphicsSystem = require('systems.graphicsSystem')

-- Allows an object in the game world with this component to cast spells from a pool of statBar.
local statBar = {}

function statBar.create(id, topPercent, heightPercent, color, getPercent)
    local c = {}
    c.id = id
    c.topPercent = topPercent
    c.heightPercent = heightPercent
    c.color = color
    c.getPercent = getPercent
    graphicsSystem:addStatBar(c)
    return c
end

return statBar
