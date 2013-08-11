-- The settings menu for the game

require('genMenu')

settings = {}

function settings.load()
    -- menu initiliazation
    genMenu:load({"controls", "graphics", "gameplay", "back to main menu"})
end

function settings.draw()
    -- draw menu text
    genMenu:drawItems()
end

function settings.keypressed(key)
    genMenu:keypressed(key)
end
