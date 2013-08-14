--For casting spells.
local Class = require('HardonCollider.class')
VisibleIcon = Class
{
    name = 'VisibleIcon',
    function(self, img, x, y, dateBorn)
        self.img = img
        self.maxAge = 4
        -- center returns vertices as x1,y1,x2,y2, ..., xn,yn
        print('center = ('..x..', '..y..') dateBorn = '..dateBorn)
        self.x = x
        self.y = y
        self.dateBorn = dateBorn
    end
}

function VisibleIcon:draw()
    love.graphics.draw(self.img, self.x, self.y)
end
