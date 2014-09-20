local Referencer = require 'lib.middleclass'('Referencer',
                 require 'components.Component')

function Referencer:initialize(parentId)
    self.parentId = parentId
end

return Referencer
