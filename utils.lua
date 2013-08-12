-- General utility functions

function setColorInverted(color)
    love.graphics.setColor(255 - color.r, 255 - color.g,
    255 - color.b)
end

function setColor(color)
    love.graphics.setColor(color.r, color.g, color.b)
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1))
end
