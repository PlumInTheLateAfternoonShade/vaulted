-- Used for status bars in the gui.
local StatBar = require 'lib.middleclass'('StatBar',
                 require 'components.Component')

function StatBar:initialize(topPercent, heightPercent, color, getPercent)
    self.topPercent = topPercent
    self.heightPercent = heightPercent
    self.color = color
    self.getPercent = getPercent
end

return StatBar
