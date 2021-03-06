local utils = require 'utils'
local Point = require 'geometry.Point'

local function rgbVary(num)
    return limit(num + math.random()*40 - 20, 0, 255)
end

local function createElementPrototype(name, color, friction, density, temp, gravScale, hardness)
    local e = {}
    e.name = name
    e.color = color
    e.friction = friction
    e.density = density
    e.temp = temp
    e.gravScale = gravScale or 1
    e.hardness = hardness
    return e
end

-- Grants an elemental association to the entity. 
local element = 
{
    fire = createElementPrototype('fire', {r = 240, b = 0, g = 70}, 0.2, 2.5, 500, nil, 2),
    ice = createElementPrototype('ice', {r = 100, b = 240, g = 150, a = 200}, 0.05, 5, 100, nil, 5),
    earth = createElementPrototype('earth', {r = 100, b = 50, g = 120}, 0.5, 10, 300, nil, 9),
    air = createElementPrototype('air', {r = 220, b = 255, g = 225}, 0, 0, 300, 0, 1),
    i = 1 -- current index for gesture screen
}
-- Create numerical indexes for gesture screen
element[1], element[2] = element.fire, element.ice
element[3], element[4] = element.earth, element.air

function element.colorVary(color)
    color.r = rgbVary(color.r)
    color.g = rgbVary(color.g)
    color.b = rgbVary(color.b)
end

function element:inc(amount)
    local amount = amount or 1
    wrappedInc(self, amount)
    setColor(self[self.i].color)
end

function element:get()
    return self[self.i]
end

function element:getName()
    return self[self.i].name
end

function element:getColor()
    return self[self.i].color
end

function element:getEleFromColor(color)
    for j = 1, #self do
        if self[j].color.r == color.r and
           self[j].color.g == color.g and
           self[j].color.b == color.b then
            return self[j]
        end
    end
    return nil
end

function element:setAsColor()
    setColor(self[self.i].color)
end

return element
