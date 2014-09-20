local Referencer = require('components.Referencer')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles reference components.
local ReferenceSystem = require('lib.middleclass')(
    'ReferenceSystem', ComponentSystem)

function ReferenceSystem:init(entities)
    self.components = entities[Referencer]
end

function ReferenceSystem:getParent(id)
    local comp = self:get(id)
    if comp then return comp.parentId end
end

return ReferenceSystem:new()
