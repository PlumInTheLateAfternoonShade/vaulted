-- Allows an object in the game world with this component to have a dynamic walker.

local Walker = require 'lib.middleclass'('Walker',
                 require 'components.Component')

function Walker:initialize(force, targetVeloc)
    self.force = force
    self.targetVeloc = targetVeloc
    self.facing = 1
    self.direction = 0
end

return Walker
