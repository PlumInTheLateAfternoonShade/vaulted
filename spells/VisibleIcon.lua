require('lib.deepcopy.deepcopy')

--For casting spells.
local Class = require('class')
local VisibleIcon = Class
{
    name = 'VisibleIcon',
    function(self, lines, x, y, dateBorn, scaleFactor)
        self.lines = table.deepcopy(lines)
        self.scaleFactor = scaleFactor or tileSize/4
        for i = 1, #self.lines do
            self.lines[i]:scale(self.scaleFactor)
            self.lines[i]:offset(x, y)
        end
        
        self.maxAge = 0.4
        self.dateBorn = dateBorn
    end
}

function VisibleIcon:draw()
    local currWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(self.scaleFactor/4)
    for i = 1, #self.lines do
        self.lines[i]:draw()
    end
    love.graphics.setLineWidth(currWidth)
end

return VisibleIcon
