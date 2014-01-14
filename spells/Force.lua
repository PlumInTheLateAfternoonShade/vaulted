local Class = require('class')
local Effect = require('spells.Effect')
-- An effect that imparts a force on objects it encounters.
local Force = Class
{
    name = 'Force',
    function(self, h, v, x, y)
        self.name = 'Force'
        self.h = h
        self.v = v
        self.x = x
        self.y = y
    end
}
Force:inherit(Effect)

function Force:apply(world, caster)
    local x, h = self:mirrorIfLeftFacing(caster.facingRight)
    local y = self.y
    local v = self.v
    local adjX = caster.body:getX() + x
    local adjY = caster.body:getY() + y
    print('Caster center x: '..caster.body:getX()..' y: '..caster.body:getY())
    print('Applying a force at '..string.format("x:%.2f, y: %.2f, h: %.2f, v: %.2f", adjX, adjY, h, v))
    table.insert(rayCastStack, {x1 = adjX, y1 = adjY, x2 = adjX + h*1000, 
    y2 = adjY + v*1000, func = forceRayCallBack, h = h, v = v})
end

function Force:mirrorIfLeftFacing(rightFacing)
    if rightFacing ~= -1 then
        return self.x, self.h
    end
    local x = self.x * rightFacing
    local h = self.h * rightFacing
    return x, h
end

--[[function forceRayCallBack(fixture, x, y, xn, yn, fraction)
    local h = rayCastStack[#rayCastStack].h
    local v = rayCastStack[#rayCastStack].v
    print('Applying an impulse of'..string.format('h: %.2f v: %.2f', 
    h, v)..' to '..fixture:getUserData()..'.')
    fixture:getBody():applyLinearImpulse(h, v)
    return 1
end]]--

return Force
