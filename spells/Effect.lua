local Class = require('class')
require 'lib.deepcopy.deepcopy'
require 'geometry.Point'

-- Basic superclass for the effect a region has on the world.
local Effect = Class
{
    name = 'Effect',
    function(self, points, center)
        self.name = 'Effect'
        self.points = points
        self.center = center
    end
}

function Effect:mirrorIfLeftFacing(rightFacing)
    if rightFacing ~= -1 then
        return self.points, self.center
    end
    local points = mirrorXListOfPoints(self.points)
    local center = mirrorXPoint(self.center)
    return points, center
end

return Effect
