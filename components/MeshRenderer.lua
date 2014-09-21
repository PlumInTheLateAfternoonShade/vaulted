-- Allows an object in the game world with this component to be colored as a mesh.
local MeshRenderer = require 'lib.middleclass'('MeshRenderer',
                 require 'components.Component')

function MeshRenderer:initialize(color, imageName, shouldPreview)
    self.color = color
    self.imageName = imageName
    self.firstUpdate = true
    self.shouldPreview = shouldPreview
end

return MeshRenderer
