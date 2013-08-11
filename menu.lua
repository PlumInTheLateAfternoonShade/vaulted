-- The main menu for the game

require('genMenu')

menu = {}

function menu.load()
    -- menu initiliazation
    genMenu:load({"continue", "new game", "settings", "exit"})
end

function menu.draw()
    -- draw menu title
    love.graphics.draw(imgs["menuTitle"], 0, 50, 0, scale, scale)
    -- draw menu text
    genMenu:drawItems()
end

function menu.keypressed(key)
    genMenu:keypressed(key)
end
