local keys = require 'keys'
local GenMenu = require 'menus.genMenu'

-- The settings menu for the game
local Resolution = require 'class'
{
    name = 'Resolution',
    function(self)
        -- menu initiliazation
        self.genMenu = GenMenu({"800 x 600",
                                "1024 x 768",
                                "1600 x 900",
                                "1920 x 1080",
                                "graphics"})
    end
}
Resolution:inherit(require 'state')

function Resolution:draw()
    -- draw menu text
    self.genMenu:drawItems()
end

function Resolution:keypressed(key)
    if key == keys.confirm then
        self:setResolution(self.genMenu:getCurrentItem())
        self.genMenu:setToLastItem()
    end
    self.genMenu:keypressed(key)
end

function Resolution:setResolution(stringRepresentation)
    local splitIndex = stringRepresentation:find('x')
    if splitIndex == nil then
        return
    end
    conf.screenWidth = tonumber(stringRepresentation:sub(0, splitIndex - 2))
    conf.screenHeight = tonumber(stringRepresentation:sub(splitIndex + 2))
    love.window.setMode(conf.screenWidth, conf.screenHeight)
end

return Resolution
