-- General utility functions

function setColorInverted(color)
    love.graphics.setColor(255 - color.r, 255 - color.g,
    255 - color.b)
end

function setColor(color)
    love.graphics.setColor(color.r, color.g, color.b)
end

function getColor()
    red, green, blue = love.graphics.getColor()
    return {r = red, g = green, b = blue}
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1))
end

function distanceSquared(x1, y1, x2, y2)
    return (x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1)
end

function within(x, x1, x2)
    big = math.max(x1, x2)
    little = math.min(x1, x2)
    return x >= little and x <= big
end

function wrappedInc(obj, amount)
    obj.i = obj.i + amount
    if obj.i < 1 then
        obj.i = #obj
    elseif obj.i > #obj then
        obj.i = 1
    end
end
