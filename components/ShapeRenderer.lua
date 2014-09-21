-- Allows an object in the game world with this component to be colored as a shape.
local ShapeRenderer = require 'lib.middleclass'('ShapeRenderer',
                 require 'components.Component')

function ShapeRenderer:initialize(color, shouldPreview)
    self.color = color
    self.shouldPreview = shouldPreview 
end

return ShapeRenderer
