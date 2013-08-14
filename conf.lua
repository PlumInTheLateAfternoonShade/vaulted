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

-- Map settings
tileSize = 16
iconSize = tileSize * 2

-- Element colors
fireColor = {r = 240, b = 0, g = 70}
waterColor = {r = 40, b = 240, g = 70}
earthColor = {r = 100, b = 50, g = 120}
airColor = {r = 220, b = 255, g = 225}

-- Elements
--[[elements = {fire = {c = fireColor}, 
            water = {c = waterColor},
            earth = {c = earthColor},
            air = {c = airColor}}]]--

-- Gesture grid settings
gridSize = 16
gridXOffset = screenWidth / 4
gridYOffset = screenHeight / 8

function love.conf(t)
    t.title = "Vaulted"
    t.screen.width = screenWidth
    t.screen.height = screenHeight
    t.vsync = false
    t.screen.fullscreen = false
end
