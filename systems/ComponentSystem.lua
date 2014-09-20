-- Table to define a template for handling components.
local ComponentSystem = require('lib.middleclass')('ComponentSystem')

function ComponentSystem:init(referenceSystem)
    self.referenceSystem = referenceSystem
end

function ComponentSystem:add(comp)
    self.components[comp.id] = comp
end

function ComponentSystem:get(id)
    if self.components and id then
        if self.components[id] then
            return self.components[id]
        elseif self.referenceSystem then
            return self:get(self.referenceSystem:getParent(id))
        end
    end
    return nil
end

function ComponentSystem:delete(id)
    self.components[id] = nil
end

function ComponentSystem:update(dt)
end

return ComponentSystem
