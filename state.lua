-- The base class for a game state, with empty methods. Useful so that we
-- don't have to redefine each empty method in states that don't care about
-- mouse input, for example.
local Class = require('HardonCollider.class')
State = Class
{
    name = 'State',
    function(self)
    end
}

function State:load()
end

function State:draw()
end

function State:update(dt)
end

function State:keypressed(key)
end

function State:keyreleased(key)
end

function State:mousepressed(x, y, button)
end

function State:mousereleased(x, y, button)
end
