--For casting spells.
local Class = require('HardonCollider.class')
VisibleIcon = Class
{
    name = 'VisibleIcon',
    function(self, lines, x, y, dateBorn)
        self.lines = lines
        for i = 1, #self.lines do
            self.lines[i]:scale(2)
            self.lines[i]:offset(x, y)
        end
        self.maxAge = 4
        -- center returns vertices as x1,y1,x2,y2, ..., xn,yn
        print('center = ('..x..', '..y..') dateBorn = '..dateBorn)
        self.dateBorn = dateBorn
    end
}

function VisibleIcon:draw()
    for i = 1, #self.lines do
        self.lines[i]:draw()
    end
end
