require 'Point'
local Class = require('HardonCollider.class')
Seg = Class
{
    name = 'Seg',
    function(self, p0, p1, c)
        self.p0 = p0
        self.p1 = p1
        self.c = c
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
