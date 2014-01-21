-- Provides the UI for making new spell gestures.
local keys = require 'keys'

local ControlSet = require 'class'
{
    name = 'ControlSet',
    function(self, purpose, key)
        self.purpose = purpose
        if type(purpose) == "number" then
            purpose = "casting spell "..purpose
        end
        self.text = "The current key for "..purpose.." is "..key..". Press a new key to change it."
    end
}
ControlSet:inherit(require 'state')

function ControlSet:draw()
    setColor({r = 255, g = 255, b = 255})
    love.graphics.printf(self.text,
    0, conf.screenHeight * 0.4, conf.screenHeight * 0.6, "center")
end

function ControlSet:keypressed(key)
    for purpose, k in pairs(keys) do
        if k == key then
            keys[purpose] = "NOT SET"
        end
    end
    for index, k in ipairs(keys.spells) do
        if k == key then
            keys.spells[index] = "NOT SET"
        end
    end
    if type(self.purpose) == "number" then
        keys.spells[self.purpose] = key
    else
        keys[self.purpose] = key
    end
    updateState("controls")
end

return ControlSet
