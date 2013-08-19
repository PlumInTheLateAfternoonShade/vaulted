-- The settings menu for the game

require('menus.genMenu')
local Class = require('HardonCollider.class')
require('state')

Settings = Class
{
    name = 'Settings',
    function(self)
        -- menu initiliazation
        self.genMenu = GenMenu({"controls", "graphics", "gameplay", 
                           "back to main menu"})
    end
}
Settings:inherit(State)

function Settings:draw()
    -- draw menu text
    self.genMenu:drawItems()
end

function Settings:keypressed(key)
    self.genMenu:keypressed(key)
end
