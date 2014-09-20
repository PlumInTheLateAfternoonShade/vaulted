-- Allows an object in the game world to become more powerful as it progresses to the right.
local Experience = require 'lib.middleclass'('Experience',
                 require 'components.Component')

function Experience:initialize(experienceMult, experienceOffset)
    self.farthestX = 0
    self.xp = 0
    self.xpMult = experienceMult or 100
    self.xpOffset = experienceOffset or 0
end

return Experience
