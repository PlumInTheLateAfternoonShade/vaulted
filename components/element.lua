require 'lib.deepcopy.deepcopy'
local Point = require 'geometry.Point'
local eleSystem = require 'systems.eleSystem'

local function createElementPrototype(name, color, friction, density, temp, gravScale)
    local e = {}
    e.name = name
    e.color = color
    e.friction = friction
    e.density = density
    e.temp = temp
    e.gravScale = gravScale or 1
    return e
end

-- Grants an elemental association to the entity. 
local element = 
{
    fire = createElementPrototype('fire', fireColor, 0.2, 2.5, 500),
    ice = createElementPrototype('ice', waterColor, 0.05, 5, 100),
    earth = createElementPrototype('earth', earthColor, 0.5, 10, 300),
    air = createElementPrototype('air', airColor, 0, 0, 300, 0)
}

local function rgbVary(num)
    return limit(num + math.random()*40 - 20, 0, 255)
end

local function colorVary(color)
    color.r = rgbVary(color.r)
    color.g = rgbVary(color.g)
    color.b = rgbVary(color.b)
end

function element.create(id, name)
    local c = table.deepcopy(element[name])
    c.id = id
    -- Make the color slightly varied
    colorVary(c.color)
    eleSystem:add(c)
    return c
end

return element
