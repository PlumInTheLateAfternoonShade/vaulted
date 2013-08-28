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

function Point:magnitude()
    return math.sqrt(self:magSquared())
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

function mirrorPoint(point, shouldX, shouldY)
    local shouldX = shouldX or false
    local shouldY = shouldY or false
    local mirPoint = Point(point.x, point.y)
    if shouldX then
        mirPoint.x = -1.0 * point.x
    end
    if shouldY then
        mirPoint.y = -1.0 * point.y
    end
    return mirPoint
end

function mirrorXPoint(point)
    return mirrorPoint(point, true)
end

function mirrorYPoint(point)
    return mirrorPoint(point, false, true)
end

function mirrorXYPoint(point)
    return mirrorPoint(point, true, true)
end

dot = function(p0, p1)
    return p0.x * p1.x + p0.y * p1.y
end

equals = function(p0, p1)
    return p0.x == p1.x and p0.y == p1.y
end

function mirrorXListOfPoints(points)
    local mirroredPoints = {}
    for i = 1, #points do
        mirroredPoints[i] = mirrorXPoint(points[i])
    end
    return mirroredPoints
end

function computeCentroid(points)
    --From http://en.wikipedia.org/wiki/Centroid#Locating_the_centroid
    local cx = 0
    local cy = 0
    local a = 0
    for i = 1, #points - 1 do
        local p0 = points[i]
        local p1 = points[i + 1]
        cx = cx + (p0.x + p1.x)*(p0.x*p1.y - p1.x*p0.y)
        cy = cy + (p0.y + p1.y)*(p0.x*p1.y - p1.x*p0.y)
        a = a + (p0.x*p1.y - p1.x*p0.y)
    end
    a = a/2
    if a ~= 0 then
        cx = cx/(6*a)
        cy = cy/(6*a)
    end
    return Point(cx, cy)
end

return Point
