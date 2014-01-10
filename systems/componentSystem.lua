-- Abstract class to define a template for handling components.
local ComponentSystem = Class
{
    name = 'ComponentSystem',
    function(self)
        self.components = {}
    end
}


function ComponentSystem:add(comp)
    self.components[comp.id] = comp
end

function ComponentSystem:get(id)
    return self.components[id]
end

function ComponentSystem:delete(id)
    self.components[id] = nil
end

function ComponentSystem:update(dt)
end

return ComponentSystem
