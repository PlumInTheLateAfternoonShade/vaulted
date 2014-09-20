local Point = require 'geometry.Point'

-- Allows an object in the game world with this component to have a dynamic position.
local Position = require 'lib.middleclass'('Position',
                 require 'components.Component')

function Position:initialize(coords, center, shape, radius)
    self.coords = coords
    if self.coords and self.coords[1] and self.coords[1] ~= 'number' then
        self.coords = Point.pointsToCoordsTable(self.coords)
    end
    self.center = center
    self.shape = shape or 'polygon'
    self.radius = radius
    self.shouldPreview = true
end

return Position
