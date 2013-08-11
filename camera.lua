camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1

function camera:set()
    love.graphics.push()
    love.graphics.scale(self.scaleX, self.scaleY)
    love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
    love.graphics.pop()
end

function camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function camera:rotate(dr)
    self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
    self.scaleX = self.scaleX * sx
    self.scaleY = self.scaleY * sy
end

function camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function camera:setScale(sx, sy)
    self.scaleX = sx
    self.scaleY = sy
end
