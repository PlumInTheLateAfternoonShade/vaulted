-- Allows an object in the game world with this component to have a dynamic temperature.
local Temperature = require 'lib.middleclass'('Temperature',
                 require 'components.Component')

function Temperature:initialize(initTemp)
    self.ambientTemp = initTemp
    self.temp = self.ambientTemp
end

return Temperature
