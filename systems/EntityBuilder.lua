local EntityBuilder = require 'lib.middleclass'('EntityBuilder')

local function initComponentMethods(self, entities)
    for CompClass, compTable in pairs(entities) do
        if CompClass.name then --TODO delete when all components middleclass
            local function addSpecificComponentByName(self, ...)
                local c = CompClass:new(...)
                self:add(c)
                return self, c
            end
            self[CompClass.name] = addSpecificComponentByName
        end
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
    assert(type(self.inUseId) == 'number', 'id must be number')
    comp.id = self.inUseId
    print("ebadd: "..tostring(comp))
    if not comp.class then
        for key, value in pairs(comp) do
            print(tostring(key).." : "..tostring(value))
        end
        error("Only objects can be added.")
    end
    print("class: "..comp.class.name..' id: '..self.inUseId)
    assert(comp.class == require('components.'..comp.class.name))
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

function EntityBuilder:finalize()
    self.inUseId = nil
end

return EntityBuilder
