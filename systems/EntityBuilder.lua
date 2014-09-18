local EntityBuilder = require 'lib.middleclass'('EntityBuilder')

local function initComponentAspects(listOfSystems)
    local componentAspects = {}
    for i = 1, #listOfSystems do
        for j = 1, #listOfSystems[i].aspect do
            local cAspects = componentAspects[listOfSystems[i].aspect[j]]
            if not cAspects then
                cAspects = {}
            end
            table.insert(cAspects, listOfSystems[i])
        end
    end
    return componentAspects
end

local function initComponentMethods(self, listOfComponents)
    for i = 1, #listOfComponents do
        local CompClass = listOfComponents[i]
        local function addSpecificComponentByName(...)
            local c = CompClass:new(...)
            self:add(c)
            return self, c
        end
        self[CompClass.name] = addSpecificComponentByName
    end
end

function EntityBuilder:initialize(listOfSystems, listOfComponents, entitySystem)
    self.entitySystem = entitySystem
    self.inUseId = nil
    self.listOfSystems = listOfSystems
    self.componentAspects = initComponentAspects(listOfSystems)
    initComponentMethods(self, listOfComponents)
end

function EntityBuilder:add(comp)
    if not self.inUseId then
        error('Must notify EntityBuilder of id to use before adding component.')
    end
    comp.id = self.inUseId
    local cAspects = self.componentAspects[comp.class]
    for i = 1, #cAspects do
        cAspects[i]:add(comp)
    end
    return self
end

function EntityBuilder:withId(id)
    self.inUseId = id
end

function EntityBuilder:withNewId()
    self.inUseId = self.entitySystem:register()
end

return EntityBuilder
