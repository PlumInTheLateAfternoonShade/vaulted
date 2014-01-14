local physicsSystem = require 'systems.physicsSystem'
-- Handles walking components.
local walkingSystem = {}

require('systems.componentSystem'):inherit(walkingSystem)

function walkingSystem:update(dt)
    for id, comp in pairs(self.components) do
        if comp.direction ~= 0 then
            -- TODO normalize for all dts.
            physicsSystem:get(id).body:applyForce(comp.force * comp.direction, 0)
        end
    end
end

function walkingSystem:getDirection(id)
    if self.components[id] then
        return self.components[id].direction
    end
    return 0
end

function walkingSystem:startWalkingRight(id)
    if self.components[id] then
        self.components[id].direction = 1
    end
end

function walkingSystem:startWalkingLeft(id)
    if self.components[id] then
        self.components[id].direction = -1
    end
end

function walkingSystem:stopWalkingRight(id)
    local comp = self.components[id]
    if comp and comp.direction == 1 then
        self.components[id].direction = 0
    end
end 

function walkingSystem:stopWalkingLeft(id) 
    local comp = self.components[id]
    if comp and comp.direction == -1 then
        self.components[id].direction = 0
    end
end

return walkingSystem
