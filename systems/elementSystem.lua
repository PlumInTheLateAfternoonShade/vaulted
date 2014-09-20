local ElementInstance = require 'components.ElementInstance'
local ComponentSystem = require('systems.ComponentSystem')

-- Handles ele components.
local ElementSystem = require('lib.middleclass')(
    'ElementSystem', ComponentSystem)

function ElementSystem:init(referenceSystem, entities)
    self.components = entities[ElementInstance]
    ComponentSystem.init(self, referenceSystem)
end

local elementSystemInstance = ElementSystem:new()
return elementSystemInstance
