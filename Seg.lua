require 'utils'
require 'Point'
local Class = require('HardonCollider.class')
Seg = Class
{
    name = 'Seg',
    function(self, p0, p1, c)
        self.p0 = p0
        self.p1 = p1
        self.c = c
        -- For spell usage. Whether it's been inserted into a region yet.
        self.regioned = false
    end
}

function Seg:distToPointSquared(a)
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
    rxsr = 1 / rxs
    t = CmPxs * rxsr
    u = CmPxr * rxsr
    return (t >= 0) and (t <= 1) and (u >= 0) and (u <= 1)
end

function Seg:sharesAPoint(seg)
    return equals(self.p0, seg.p0) or equals(self.p0, seg.p1) or
    equals(self.p1, seg.p0) or equals(self.p1, seg.p1)
end

function Seg:compress()
    -- Compresses a segment into 1, 16.
    -- Ah, the joys of OO! Eventually you will get so bored
    -- following the rabbit hole down that you will give up.
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

function Seg:scale(value)
    self.p0:scale(value)
    self.p1:scale(value)
end
function Seg.__tostring(r)
    return tostring(r.p0)..','..tostring(r.p1)
end
