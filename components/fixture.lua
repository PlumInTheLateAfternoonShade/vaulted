local fixtureSystem = require 'systems.fixtureSystem'

-- Attaches a body component to a shape component
local fixture = {}

function fixture.prototype(friction)
    local c = 
    { 
        name = 'fixture',
        firstUpdate = true,
        friction = friction,
    }
    function c:addToSystems(id, bodyId)
        self.id = id
        self.bodyId = bodyId
        fixtureSystem:add(self)
    end
    return c
end

function fixture.create(id, bodyId, ...)
    local c = fixture.prototype(...)
    c:addToSystems(id, bodyId)
    return c
end

return fixture
