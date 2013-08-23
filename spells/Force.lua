local Class = require('class')
local Effect = require('spells.Effect')
require('camera') --Testing
local currentForce
-- An effect that imparts a force on objects it encounters.
local Force = Class
{
    name = 'Force',
    function(self, h, v, x, y)
        self.h = h
        self.v = v
        self.x = x
        self.y = y
    end
}
Force:inherit(Effect)

function Force:apply(world, caster)
    self.x = caster.body:getX()
    self.y = caster.body:getY() + tileSize*2 --TODO Placeholder
    print('Applying a force at '..string.format("x:%.2f, y: %.2f, h: %.2f, v: %.2f", self.x, self.y, self.h, self.v))
    currentForce = self
    world:rayCast(self.x, self.y, self.x + self.h*1000, self.y + self.v*1000,
    forceRayCallBack)
end

function forceRayCallBack(fixture, x, y, xn, yn, fraction)
    print('Applying an impulse of'..string.format('h: %.2f v: %.2f', 
          currentForce.h, currentForce.v)..' to '..fixture:getUserData()..'.')
    fixture:getBody():applyLinearImpulse(currentForce.h, currentForce.v)
    return 1
end

return Force
