local physicsSystem = require 'systems.physicsSystem'
local Welder = require('components.Welder')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles joint components.
local JointSystem = require('lib.middleclass')(
    'JointSystem', ComponentSystem)

function JointSystem:init(entities)
    self.components = entities[Welder]
end

function JointSystem:update(dt)
    for id, comp in pairs(self.components) do
        if comp.firstUpdate then
            comp.joint = love.physics.newWeldJoint(
            physicsSystem:get(comp.id1).body,
            physicsSystem:get(comp.id2).body,
            comp.point.x, comp.point.y,
            comp.shouldCollide)
            comp.firstUpdate = false
        end
    end
end

return JointSystem:new()
