-- Abstract base class for components.
local Component = require 'lib.middleclass'('Component')

function Component:addToSystems(id)
    self.id = id
    for i = 1, #self.systems do
        self.systems[i]:add(self)
    end
end

return Component
