-- The settings menu for the game

local GenMenu = require('menus.genMenu')
local Class = require('class')
local State = require('state')

local Graphics = Class
{
    name = 'Graphics',
    function(self)
        -- menu initiliazation
        self.genMenu = GenMenu({"resolution",
                           "settings"})
    end
}
Graphics:inherit(State)

function Graphics:draw()
    -- draw menu text
    self.genMenu:drawItems()
end

function Graphics:keypressed(key)
    self.genMenu:keypressed(key)
end

return Graphics
