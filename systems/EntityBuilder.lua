local EntityBuilder = require 'lib.middleclass'('EntityBuilder')

local function initComponentMethods(self, entities)
    for CompClass, compTable in pairs(entities) do
        local function addSpecificComponentByName(self, ...)
            local c = CompClass:new(...)
            self:add(c)
            return self, c
        end
        self[CompClass.name] = addSpecificComponentByName
    end
end

function EntityBuilder:initialize(entities, entitySystem)
    self.entitySystem = entitySystem
    self.entities = entities
    self.inUseId = nil
    initComponentMethods(self, entities)
end

function EntityBuilder:add(comp)
    if not self.inUseId then
        error('Must notify EntityBuilder of id to use before adding component.')
    end
    comp.id = self.inUseId
    print("class: "..comp.class.name)
    assert(comp.class == require 'components.Force')
    self.entities[comp.class][comp.id] = comp
    return self
end

function EntityBuilder:withId(id)
    self.inUseId = id
    return self
end

function EntityBuilder:withNewId()
    self.inUseId = self.entitySystem:register()
    return self
end

return EntityBuilder
