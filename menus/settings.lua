-- The settings menu for the game

local GenMenu = require('menus.genMenu')
local Class = require('class')
local State = require('state')

local Settings = Class
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

return Settings
