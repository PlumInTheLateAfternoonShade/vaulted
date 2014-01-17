require 'utils'
require 'lib.deepcopy.deepcopy'
Point = require('geometry.Point')
local Class = require('class')
local Seg = Class
{
    name = 'Seg',
    function(self, p0, p1, c, table)
        if table ~= nil then
            self.p0 = Point(nil, nil, table.p0)
            self.p1 = Point(nil, nil, table.p1)
            self.c = table.c
            self.regioned = table.regioned
        else
            self.p0 = p0
            self.p1 = p1
            self.c = c
            -- For spell usage. Whether it's been inserted into a region yet.
            self.regioned = nil
        end
    end
}

function Seg:distToPointSquared(a)
    -- TODO: this is wrong.
    local dotProd = dot(a - self.p0, self.p1 - self.p0)
    if dotProd <= 0 then
        local sub = a - self.p0
        print("sub: "..tostring(sub).." a: "..tostring(a).."self.p0:"..tostring(self.p0))
        return sub:magSquared()
    end
    local sub = self.p1 - self.p0
    print("sub: "..tostring(sub).." self.p1: "..tostring(self.p1).."self.p0:"..tostring(self.p0))
    local l = sub:magSquared()
    local s = dotProd*dotProd/l
    if s > l then
        local sub = a - self.p1
        print("sub: "..tostring(sub).." a: "..tostring(a).."self.p1:"..tostring(self.p1))
        return sub:magSquared()
    end
    return s
end

function Seg:lengthSquared()
    return (self.p1.x - self.p0.x) * (self.p1.x - self.p0.x)
    + (self.p1.y - self.p0.y) * (self.p1.y - self.p0.y)
end

function Seg:length()
    return math.sqrt(self:lengthSquared())
end

function Seg:intersects(seg)
    -- Quick port from Matt's answer at 
    -- http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect?rq=1
    -- Also returns true if the lines share a point, 
    -- which counts for my purposes.
    local A, B, C, D = self.p0, self.p1, seg.p0, seg.p1

    if self:sharesAPoint(seg) then
        -- Lines share a point, so they intersect.
        return true
    end
    print('A: '..tostring(A)..' B: '..tostring(B)..' C: '..tostring(C)..' D: '
    ..tostring(D))
    local CmP = Point(C.x - A.x, C.y - A.y)
    local r = Point(B.x - A.x, B.y - A.y)
    local s = Point(D.x - C.x, D.y - C.y)

    local CmPxr = CmP.x * r.y - CmP.y * r.x
    local CmPxs = CmP.x * s.y - CmP.y * s.x
    local rxs = r.x * s.y - r.y * s.x

    if (CmPxr == 0) then
        -- Lines are collinear, and so intersect if they have any overlap
        return ((C.x - A.x < 0) ~= (C.x - B.x < 0))
        or ((C.y - A.y < 0) ~= (C.y - B.y < 0))
    end

    if (rxs == 0) then
        return false -- Lines are parallel.
    end
    local rxsr = 1 / rxs
    local t = CmPxs * rxsr
    local u = CmPxr * rxsr
    return (t >= 0) and (t <= 1) and (u >= 0) and (u <= 1)
end

function Seg:getIntersectionAsLines(line)
    -- Get the intersection point as if the segs were infinite lines.
    -- From http://community.topcoder.com/tc?module=Static&d1=tutorials&d2=geometry2#line_line_intersection

    local A0, B0, C0 = self:convertToABC()
    local A1, B1, C1 = line:convertToABC()
    local det = A0*B1 - A1*B0
    if det == 0 then
        --Lines are parallel
        return nil
    end
    local x = (B1*C0 - B0*C1)/det
    local y = (A0*C1 - A1*C0)/det
    return Point(x, y)
end

function Seg:convertToABC()
    --Convert to Ax + By = C form
    local A = self.p1.y - self.p0.y
    local B = self.p0.x - self.p1.x
    local C = A*self.p0.x + B*self.p0.y
    return A, B, C
end

function Seg:hasPoint(point)
    local A, B, C = self:convertToABC()
    print(tostring(A*point.x)..'~'..tostring(B*point.y))
    if A*point.x + B*point.y ~= C then
        print('returning false one')
        --TODO: Floating point errors here?
        return false
    end
    print('point.x: '..point.x..' p0.x: '..self.p0.x..' p1.x: '..self.p1.x)
    print('point.y: '..point.y..' p0.y: '..self.p0.y..' p1.y: '..self.p1.y)
    if within(point.x, self.p0.x, self.p1.x)
        and within(point.y, self.p0.y, self.p1.y) then
        return true
    end
    print('returning false two')
    return false
end

function Seg:findSidePointIsOn(point)
    -- Return a positive number if above the seg's line, 0 if on it,
    -- and a negative number if below it.
    local A, B, C = self:convertToABC()
    return point.x*A + point.y*B - C
end

function Seg:sharesAPoint(seg)
    if equals(self.p0, seg.p0) or equals(self.p0, seg.p1) then
        return self.p0
    elseif equals(self.p1, seg.p0) or equals(self.p1, seg.p1) then
        return self.p1
    end
    return false
end

function Seg:compress()
    -- Compresses a segment into 1, 16.
    self.p0:compress()
    self.p1:compress()
end

function Seg:decompress()
    -- TODO?
end

function Seg:draw()
    local currColor = getColor()
    setColor(self.c)
    love.graphics.line(self.p0.x, self.p0.y, self.p1.x, self.p1.y)
    setColor(currColor)
end

function Seg:offset(x, y)
    self.p0:offset(x, y)
    self.p1:offset(x, y)
end

function offsetListOfSegs(segs, x, y)
    local newSegs = {}
    for i = 1, #segs do
        newSegs[i] = objectDeepcopy(segs[i])
        newSegs[i]:offset(x, y)
    end
    return newSegs
end

function Seg:scale(value)
    self.p0:scale(value)
    self.p1:scale(value)
end

function Seg:getAngle()
    local dx = self.p0.x - self.p1.x
    local dy = self.p1.y - self.p0.y
    return math.atan2(dy, dx)
end

function Seg:getMidPoint()
    local x = (self.p0.x + self.p1.x)/2
    local y = (self.p0.y + self.p1.y)/2
    return Point(x, y)
end

function Seg:normalize()
    --Returns a vector starting at origin with length 1 and current slope.
    local angle = self:getAngle()
    local x = math.cos(angle)
    local y = math.sin(angle)
    return Point(x, y)
end

function Seg:getOtherPoint(point)
    if not point then
        return false
    end
    if self.p0:equals(point) then
        return self.p1
    elseif self.p1:equals(point) then
        return self.p0
    end
    return false
end

function mirrorXSeg(seg)
    return Seg(mirrorXPoint(seg.p0), mirrorXPoint(seg.p1), seg.c)
end

function mirrorYSeg(seg)
    return Seg(mirrorYPoint(seg.p0), mirrorYPoint(seg.p1), seg.c)
end

function mirrorXYSeg(seg)
    return Seg(mirrorXYPoint(seg.p0), mirrorXYPoint(seg.p1), seg.c)
end

function mirrorXListOfSegs(segs)
    local mirroredSegs = {}
    for i = 1, #segs do
        mirroredSegs[i] = mirrorXSeg(segs[i])
    end
    return mirroredSegs
end

function getLongestLine(lines)
    local max = 0
    local maxI = 1
    for i = 1, #lines do
        local len = lines[i]:length()
        if len > max then
            max = len
            maxI = i
        end
    end
    local j = 1
    local shorterLines = {}
    for i = 1, #lines do
        if i ~= maxI then
            shorterLines[j] = lines[i]
            j = j + 1
        end
    end
    return lines[maxI], shorterLines
end

function Seg.__tostring(r)
    return tostring(r.p0)..','..tostring(r.p1)
end

return Seg
