-- The main menu for the game

local GenMenu = require('menus.genMenu')
local Class = require 'HardonCollider.class'
local State = require 'state'
local Menu = Class
{
    name = 'menu',
    function(self)
        -- menu initiliazation
        self.genMenu = GenMenu({"continue", "new game", "settings", "exit"})
    end
}
Menu:inherit(State)

function Menu:draw()
    -- draw menu title
    love.graphics.draw(imgs["menuTitle"], 0, 50, 0, scale, scale)
    -- draw menu text
    self.genMenu:drawItems()
end

function Menu:keypressed(key)
    self.genMenu:keypressed(key)
end

return Menu
