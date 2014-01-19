-- Handles reference components.
local referenceSystem = {}

require('systems.componentSystem'):inherit(referenceSystem)

function referenceSystem:getParent(id)
    local comp = self:get(id)
    if comp then return comp.parentId end
end

return referenceSystem
