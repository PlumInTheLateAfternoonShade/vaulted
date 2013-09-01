local Class = require('class')

local boltDurationMult = 0.003
local boltWidthMult = 1

local BoltVisual = Class
{
    name = 'BoltVisual',
    function(self, lines, element, power, startTime)
        self.startTime = startTime
        self.endTime = startTime + power*boltDurationMult
        self.lines = lines
        self.element = element
        self.power = power
        self.width = self.power*boltWidthMult
    end
}

function BoltVisual:update(dt)
    if os.clock() > self.endTime then
        return false
    end
    return true
end

function BoltVisual:draw()
    local currWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(self.width)
    for i = 1, #self.lines do
        self.lines[i]:draw()
    end
    love.graphics.setLineWidth(currWidth)
end

return BoltVisual
