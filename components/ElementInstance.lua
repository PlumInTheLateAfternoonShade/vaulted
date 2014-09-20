local utils = require 'utils'
local element = require 'components.element'
local Component = require 'components.Component'
local ElementInstance = require 'lib.middleclass'('ElementInstance', Component)

function ElementInstance:initialize(name)
    local c = utils.objectDeepcopyWithoutMetatable(element[name])
    for key, value in pairs(c) do
        self[key] = value
    end
    -- Make the color slightly varied
    element.colorVary(self.color)
end

return ElementInstance
