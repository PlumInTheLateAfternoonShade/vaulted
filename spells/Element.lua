local Class = require('class')

Element = Class
{
    function(self, t, color)
        self.t = t
        self.c = color
    end
}

function Element.__tostring(e)
    return e.t
end

-- A table of elements
fire = Element('fire', fireColor)
water = Element('water', waterColor)
earth = Element('earth', earthColor)
air = Element('air', airColor)
eles = {fire, water, earth, air, i = 1}

function eles.inc(amount)
    wrappedInc(eles, amount)
    setColor(eles[eles.i].c)
end

function eles.getEleFromColor(color)
    for j = 1, #eles do
        if eles[j].c.r == color.r and
           eles[j].c.g == color.g and
           eles[j].c.b == color.b then
            return eles[j]
        end
    end
    return nil
end
