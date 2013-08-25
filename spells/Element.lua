local Class = require('class')

Element = Class
{
    function(self, t, color, friction, density, gravScale)
        self.t = t
        self.c = color
        self.friction = friction
        self.density = density
        self.gravScale = gravScale or 1
    end
}

function Element.__tostring(e)
    return e.t
end

-- A table of elements
fire = Element('fire', fireColor, 0.2, 2.5)
water = Element('water', waterColor, 0.05, 5)
earth = Element('earth', earthColor, 0.5, 10)
air = Element('air', airColor, 0, 0, 0)
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
