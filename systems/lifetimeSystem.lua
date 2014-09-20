-- Handles lifetime components.
local Lifetime = require('components.Lifetime')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles joint components.
local LifetimeSystem = require('lib.middleclass')(
    'LifetimeSystem', ComponentSystem)

function LifetimeSystem:init(referenceSystem, entitySystem)
    self.entitySystem = entitySystem
    self.components = entitySystem.entities[Lifetime]
    ComponentSystem.init(self, referenceSystem)
end

function LifetimeSystem:update(dt)
    for id, comp in pairs(self.components) do
        comp.timeAlive = comp.timeAlive + dt
        if comp.timeAlive > comp.lifetime then
            self.entitySystem:delete(id)
        end
    end
end

function LifetimeSystem:getLifetime(id)
    return self.components[id].lifetime
end

local lifetimeSystemInstance = LifetimeSystem:new()
return lifetimeSystemInstance
