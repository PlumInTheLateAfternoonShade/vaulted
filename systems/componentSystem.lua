-- Table to define a template for handling components.
local componentSystem = {}

function componentSystem:init(referenceSystem)
    self.components = {}
    self.referenceSystem = referenceSystem
end

function componentSystem:add(comp)
    self.components[comp.id] = comp
end

function componentSystem:get(id)
    if self.components and id then
        if self.components[id] then
            return self.components[id]
        elseif self.referenceSystem then
            return self:get(self.referenceSystem:getParent(id))
        end
    end
    return nil
end

function componentSystem:delete(id)
    self.components[id] = nil
end

function componentSystem:update(dt)
end

function componentSystem:inherit(table)
    setmetatable(table, {__index = self})
end

return componentSystem
