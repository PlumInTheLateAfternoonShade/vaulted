-- Allows an object in the game world with this component to be colored as a shape.
local ShapeRenderer = require 'lib.middleclass'('ShapeRenderer',
                 require 'components.Component')

function ShapeRenderer:initialize(color)
    self.color = color
    self.shouldPreview = true
end

return ShapeRenderer
