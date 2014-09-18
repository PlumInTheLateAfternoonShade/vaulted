local class = require 'lib.middleclass'

-- Abstract base class for components.
local Component = class('Component')

function Component:initialize(systems)
   self.systems = systems 
end

function Component:addToSystems(id)
    self.id = id
    for i = 1, #self.systems do
        self.systems[i]:add(self)
    end
end

return Component
