require('lib.deepcopy.deepcopy')

--For casting spells.
local Class = require('class')
local VisibleIcon = Class
{
    name = 'VisibleIcon',
    function(self, lines, x, y, dateBorn)
        self.lines = table.deepcopy(lines)
        for i = 1, #self.lines do
            self.lines[i]:scale(tileSize / 4)
            self.lines[i]:offset(x, y)
        end
        self.maxAge = 4
        -- center returns vertices as x1,y1,x2,y2, ..., xn,yn
        self.dateBorn = dateBorn
    end
}

function VisibleIcon:draw()
    local currWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(tileSize / 16)
    for i = 1, #self.lines do
        self.lines[i]:draw()
    end
    love.graphics.setLineWidth(currWidth)
end

return VisibleIcon
