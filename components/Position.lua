-- Allows an object in the game world with this component to have a dynamic position.
local Position = require 'lib.middleclass'('Position',
                 require 'components.Component')

function Position:initialize(coords, center, shape, radius)
    self.name = 'position' --TODO delete
    self.coords = coords
    self.center = center
    self.shape = shape or 'polygon'
    self.radius = radius
    self.shouldPreview = true
    self.systems = self.class.static.systems
end

return Position
