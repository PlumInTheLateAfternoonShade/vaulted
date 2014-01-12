local experienceSystem = require('systems.experienceSystem')

-- Allows an object in the game world to become more powerful as it progresses to the right.
local experience = {}

function experience.create(id, experienceMult, experienceOffset)
    local c = {}
    c.id = id
    c.farthestX = 0
    c.xp = 0
    c.xpMult = experienceMult or 1
    c.xpOffset = experienceOffset or 0
    experienceSystem:add(c)
    return c
end

return experience
