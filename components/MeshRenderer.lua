-- Allows an object in the game world with this component to be colored as a mesh.
local MeshRenderer = require 'lib.middleclass'('MeshRenderer',
                 require 'components.Component')

function MeshRenderer:initialize(color, imageName)
    self.color = color
    self.imageName = imageName
    self.needsInit = true
    self.shouldPreview = true
end

return MeshRenderer
