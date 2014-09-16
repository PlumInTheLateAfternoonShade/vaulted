-- Handles lifetime components.
local lifetimeSystem = {}

require('systems.componentSystem'):inherit(lifetimeSystem)

function lifetimeSystem:init(entitySys)
    self.entitySystem = entitySys
end

function lifetimeSystem:update(dt)
    for id, comp in pairs(self.components) do
        comp.timeAlive = comp.timeAlive + dt
        if comp.timeAlive > comp.lifetime then
            self.entitySystem:delete(id)
        end
    end
end

function lifetimeSystem:getLifetime(id)
    return self.components[id].lifetime
end

return lifetimeSystem
