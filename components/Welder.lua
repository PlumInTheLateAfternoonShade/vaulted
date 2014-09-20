-- Allows two physics components to be welded together at a point.
local Welder = require 'lib.middleclass'('Welder',
                 require 'components.Component')

function Welder:initialize(id1, id2, point, shouldCollide)
    self.id1 = id1
    self.id2 = id2
    self.point = point
    self.shouldCollide = shouldCollide or false
    self.joint = nil
    self.firstUpdate = true
end

return Welder
