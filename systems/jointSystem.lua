local physicsSystem = require 'systems.physicsSystem'
-- Handles joint components.
local jointSystem = {}

require('systems.componentSystem'):inherit(jointSystem)

function jointSystem:init()
    self.components = {}
    self.addQueue = {}
end

function jointSystem:add(comp)
    self.addQueue[comp.id] = comp
end

function jointSystem:update(dt)
    if #self.addQueue > 0 then
        for id, comp in pairs(self.addQueue) do
            local centerX, centerY = physicsSystem:get(comp.id1).body:getWorldCenter()
            love.physics.newWeldJoint(
            physicsSystem:get(comp.id1).body,
            physicsSystem:get(comp.id2).body,
            centerX, centerY,
            comp.shouldCollide)
            self.components[id] = comp
        end
        self.addQueue = {}
    end
end

return jointSystem
