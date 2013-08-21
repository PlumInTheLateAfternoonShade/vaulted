local Class = require('class')
Camera = Class
{
    name = 'Camera',
    function(self)
        self.x = 0
        self.y = 0
        self.scaleX = 1
        self.scaleY = 1
    end
}

function Camera:set()
    love.graphics.push()
    love.graphics.scale(self.scaleX, self.scaleY)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
    love.graphics.pop()
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:rotate(dr)
    self.rotation = self.rotation + dr
end

function Camera:scale(sx, sy)
    self.scaleX = self.scaleX * sx
    self.scaleY = self.scaleY * sy
end

function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function Camera:setScale(sx, sy)
    self.scaleX = sx
    self.scaleY = sy
end
