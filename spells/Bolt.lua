local Class = require('class')
local Effect = require('spells.Effect')
local Point = require('geometry.Point')
local Seg = require('geometry.Seg')
local BoltVisual = require('visuals.boltVisual')
-- An effect that casts a bolt of a specific element.
-- Bolts are shorter-range and less powerful than many spells,
-- but they can travel through certain objects (and electrocute water?)
local Bolt = Class
{
    name = 'Bolt',
    function(self, lines, element, power)
        self.name = 'Bolt'
        self.element = element
        self.lines = lines
        self.power = power
    end
}
Bolt:inherit(Effect)

function Bolt:apply(world, caster)
    print('Bolt apply of element '..self.element.t)    
    local lines
    if caster.facingRight == 1 then
        lines = self.lines
    else
        lines = mirrorXListOfSegs(self.lines)
    end
    lines = offsetListOfSegs(lines, caster.body:getX(), caster.body:getY())
    for i = 1, #lines do
        local l = lines[i]
        table.insert(rayCastStack, {x1 = l.p0.x, y1 = l.p0.y, 
        x2 = l.p1.x, y2 = l.p1.y, func = boltRayCallBack, 
        power = self.power, element = self.element})
    end
    return BoltVisual(lines, self.element, self.power, os.clock())
end

function boltRayCallBack(fixture, x, y, xn, yn, fraction)
    local power = rayCastStack[#rayCastStack].power
    local element = rayCastStack[#rayCastStack].power
    print('Applying a bolt of'..string.format(' power %.1f',
    power)..' to '..fixture:getUserData()..'.')
    for i = 1, #objects do
        if objects[i].fixture == fixture then
            objects[i]:applyBolt(power, element)
            break
        end
    end
    return 1
end

return Bolt
