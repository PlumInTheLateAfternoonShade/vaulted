-- Game Scale
scale = 1

-- Keyboard settings
gesture = "g"
up = "up"
down = "down"
openMenu = "escape"
confirm = "return"
left = "a"
right = "d"
spell1 = " "

-- Screen settings
screenWidth = 1600
screenHeight = 900

-- Element colors
fireColor = {r = 240, b = 0, g = 70}
waterColor = {r = 40, b = 240, g = 70}
earthColor = {r = 100, b = 110, g = 240}
airColor = {r = 220, b = 255, g = 225}

-- Gesture grid settings
gridSize = 15
gridXOffset = screenWidth / 4
gridYOffset = screenHeight / 8

function love.conf(t)
    t.title = "Vaulted"
    t.screen.width = screenWidth
    t.screen.height = screenHeight
    t.vsync = false
    t.screen.fullscreen = true
end
