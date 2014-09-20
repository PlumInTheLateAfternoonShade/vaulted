local keys = require 'keys'
local Input = require 'lib.middleclass'('Input',
                 require 'components.Component')
-- Allows an object in the game world with this component to have a dynamic input.

function Input:initialize(canAdministrate, canCast)
    if canAdministrate == nil then
        canAdministrate = true
    end
    if canCast == nil then
        canCast = true
    end
    self.canAdministrate = canAdministrate
    self.canCast = canCast
    self.firstUpdate = true
    self.keyPresses = {}
    self.keyReleases = {}
end

return Input
