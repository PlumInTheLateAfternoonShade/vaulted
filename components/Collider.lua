local Point = require 'geometry.Point'
-- Allows an object in the game world with this component to be collided with.
local Collider = require 'lib.middleclass'('Collider',
                 require 'components.Component')

function Collider:initialize(friction, type, breakable, initV, density,
    shouldBalance, shouldPierce, hardness)
    self.name = 'Collider'
    self.firstUpdate = true
    self.friction = friction
    self.type = type
    self.breakable = breakable or false
    self.initV = initV or Point(0, 0)
    self.density = density
    self.shouldBalance = shouldBalance or false
    self.shouldPierce = shouldPierce or false
    self.hardness = hardness or 5
    self.maxMassToBreak = 40
end

return Collider
