-- The settings menu for the game

local GenMenu = require('menus.genMenu')
local Class = require('class')
local State = require('state')

local Graphics = Class
{
    name = 'Graphics',
    function(self)
        -- menu initiliazation
        self.genMenu = GenMenu({"800 x 600",
                                "1024 x 768",
                                "1600 x 900",
                                "1920 x 1080",
                                "graphics"})
    end
}
Graphics:inherit(State)

function Graphics:draw()
    -- draw menu text
    self.genMenu:drawItems()
end

function Graphics:keypressed(key)
    if key == confirm then
        self:setResolution(self.genMenu:getCurrentItem())
        self.genMenu:setToLastItem()
    end
    self.genMenu:keypressed(key)
end

function Graphics:setResolution(stringRepresentation)
    splitIndex = stringRepresentation:find('x')
    if splitIndex == nil then
        return
    end
    conf.screenWidth = tonumber(stringRepresentation:sub(0, splitIndex - 2))
    conf.screenHeight = tonumber(stringRepresentation:sub(splitIndex + 2))
    love.window.setMode(conf.screenWidth, conf.screenHeight)
end

return Graphics
