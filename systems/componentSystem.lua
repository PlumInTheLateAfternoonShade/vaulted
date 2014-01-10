-- Table to define a template for handling components.
local componentSystem = {}

function componentSystem:init()
    self.components = {}
end

function componentSystem:add(comp)
    self.components[comp.id] = comp
end

function componentSystem:get(id)
    return self.components[id]
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
