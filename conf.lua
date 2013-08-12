-- Game Scale
scale = 1
-- Whether to print debug messages
debug = true
-- Keyboard settings
up = "up"
down = "down"
openMenu = "escape"
confirm = "return"
left = "a"
right = "d"
spell1 = " "

function love.conf(t)
    t.title = "Vaulted"
    t.screen.width = 1600
    t.screen.height = 900
    t.vsync = false
end
