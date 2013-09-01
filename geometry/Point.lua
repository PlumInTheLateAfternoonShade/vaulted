require 'lib.deepcopy.deepcopy'
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

function Point:distance(point)
    return math.sqrt(self:distanceSquared(point))
end

function Point:distanceSquared(point)
    return (point.x - self.x)*(point.x - self.x)
    + (point.y - self.y)*(point.y - self.y)
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

function ccw(p1, p2, p3)
    -- From http://en.wikipedia.org/wiki/Graham_scan
    -- 2d cross product (z-component of 3d cross product).
    -- Three points are a counter-clockwise turn if ccw > 0, clockwise if
    -- ccw < 0, and collinear if ccw = 0 because ccw is a determinant that
    -- gives the signed area of the triangle formed by p1, p2 and p3.
    return (p2.x - p1.x)*(p3.y - p1.y) - (p2.y - p1.y)*(p3.x - p1.x)
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


function computeArea(points)
    -- From http://en.wikipedia.org/wiki/Centroid#Locating_the_centroid
    local a = 0
    for i = 1, #points - 1 do
        local p0 = points[i]
        local p1 = points[i + 1]
        a = a + (p0.x*p1.y - p1.x*p0.y)
    end
    a = a/2
    return a
end

function convexHull(unsortedPoints)
    -- Finds the smallest convex polygon that encapsulates all the points.
    -- using Graham's scan. See http://en.wikipedia.org/wiki/Graham_scan
    -- and http://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain
    local points = table.deepcopy(unsortedPoints)
    -- Sort the points by Y value.
    table.sort(points, compareXthenY)
    -- TODO: Remove duplicates.
    if #points <= 2 then
        -- Can't make a polygon without a big enough input.
        return nil
    end
    -- Build lower hull
    local lower = {}
    for i = 1, #points do
        print('cHull. '..tostring(points[i]))
        local p = points[i]
        while #lower >= 2 and ccw(lower[#lower - 1], lower[#lower], p)
        <= 0 do
            table.remove(lower)
        end
        table.insert(lower, p)
    end
    -- Build upper hull
    local upper = {}
    for i = #points, 1, -1 do
        local p = points[i]
        while #upper >= 2 and ccw(upper[#upper - 1], upper[#upper], p)
        <= 0 do
            table.remove(upper)
        end
        table.insert(upper, p)
    end
    printTable('Lower', lower, '---')
    printTable('Upper', upper, '---')
    -- Concatenate the hulls, but skip the last value of each
    table.remove(lower)
    for i = 1, #upper - 1 do
        table.insert(lower, upper[i])
    end

    --[[ Switch from ccw to cw
    local hull = {}
    for i = 1, #lower, -1 do
        table.insert(hull, lower[i])
    end]]--
    if #lower < 3 then
        return unsortedPoints
    end
    return lower
end

function compareYthenX(p0, p1)
    if not p0 or not p1 then
        return false
    end
    if p0.y == p1.y then
        return p0.x <= p1.x
    end
    return p0.y <= p1.y
end

function compareXthenY(p0, p1)
    if not p0 or not p1 then
        return false
    end
    if p0.x == p1.x then
        return p0.y <= p1.y
    end
    return p0.x <= p1.x
end

function breakNearSeg(points, seg)
    -- Finds the two points closest to the seg's endpoints
    -- and returns two collections of points on either side.
    local ps = table.deepcopy(points)
    local p0, i = nearestPoint(ps, seg.p0)
    local p1, j = nearestPoint(ps, seg.p1)
    if math.abs(i - j) <= 1 then
        -- Don't break it if we wouldn't get two polygons out of it.
        return points
    end
    local side1 = {}
    local side2 = {}
    local nearSeg = Seg(p0, p1)
    for k = 1, #points do
        if nearSeg:findSidePointIsOn(points[k]) >= 0 then
            table.insert(side1, points[k])
        else
            table.insert(side2, points[k])
        end
    end
    table.insert(side1, p0)
    table.insert(side2, p0)
    table.insert(side1, p1)
    table.insert(side2, p1)
    return side1, side2
end

function nearestPoint(points, point)
    local nearestIndex = 1
    local nearestDist = worldXEnd
    for i = 1, #points do
        local dist = points[i]:distanceSquared(point)
        if dist < nearestDist then
            nearestDist = dist
            nearestIndex = i
        end
    end
    return points[nearestIndex], nearestIndex
end

return Point
