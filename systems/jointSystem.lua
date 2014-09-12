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
    for id, comp in pairs(self.addQueue) do
        print('making new joint')
        comp.joint = love.physics.newWeldJoint(
            physicsSystem:get(comp.id1).body,
            physicsSystem:get(comp.id2).body,
            comp.point.x, comp.point.y,
            comp.shouldCollide)
        self.components[id] = comp
    end
    self.addQueue = {}
end

return jointSystem
