local Class = require('HardonCollider.class')
Point = Class
{
    name = 'Point',
    function(self, x, y)
        self.x = x
        self.y = y
    end
}

function Point.__add(p0, p1)
    return Point(p0.x + p1.x, p0.y + p1.y)
end

function Point.__sub(p0, p1)
    return Point(p0.x - p1.x, p0.y - p1.y)
end

function Point.__tostring(p)
    return string.format('(%f, %f)', p.x, p.y)
end

function Point:magSquared()
    return self.x * self.x + self.y * self.y
end

dot = function(p0, p1)
    return p0.x * p1.x + p0.y * p1.y
end
