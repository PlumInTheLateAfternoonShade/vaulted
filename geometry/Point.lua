local Class = require('class')
local Point = Class
{
    name = 'Point',
    function(self, x, y, table)
        if table ~= nil then
            self.x = table.x
            self.y = table.y
        else
            self.x = x
            self.y = y
        end
    end
}

function Point.__add(p0, p1)
    return Point(p0.x + p1.x, p0.y + p1.y)
end

function Point.__sub(p0, p1)
    return Point(p0.x - p1.x, p0.y - p1.y)
end


function Point.__mult(p0, p1)
    return Point(p0.x * p1.x, p0.y * p1.y)
end

function Point.__tostring(p)
    return string.format('(%.1f, %.1f)', p.x, p.y)
end

function Point:magSquared()
    return self.x * self.x + self.y * self.y
end

function Point:compress()
    gapX = (screenWidth - 2*gridXOffset) / gridSize
    gapY = (screenHeight - 2*gridYOffset) / gridSize
    self.x = (self.x - gridXOffset) / gapX
    self.y = (self.y - gridYOffset) / gapY
end

function Point:offset(x, y)
    self.x = self.x + x
    self.y = self.y + y
end

function Point:scale(value)
    self.x = self.x * value
    self.y = self.y * value
end

function Point:equals(point)
    return self.x == point.x and self.y == point.y
end

dot = function(p0, p1)
    return p0.x * p1.x + p0.y * p1.y
end

equals = function(p0, p1)
    return p0.x == p1.x and p0.y == p1.y
end

return Point
