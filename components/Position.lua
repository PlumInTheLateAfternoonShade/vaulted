-- Allows an object in the game world with this component to have a dynamic position.
local Position = require 'lib.middleclass'('Position',
                 require 'components.Component')
Position.static.systems = { require('systems.positionSystem'), nonserializable = true }

function Position:initialize(coords, center, shape, radius)
    self.name = 'position' --TODO delete
    self.coords = coords
    self.center = center
    self.shape = shape or 'polygon'
    self.radius = radius
    self.shouldPreview = true
    self.systems = self.class.static.systems
end

function Position.create(id, ...)
    local c = Position:new(...)
    c:addToSystems(id)
    return c
end

return Position
