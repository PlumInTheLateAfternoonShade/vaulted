local loader = require('loader')

-- Game Scale
scale = 1

-- Keyboard settings
gesture = "g"
up = "up"
down = "down"
leftArrow = "left"
rightArrow = "right"
openMenu = "escape"
confirm = "return"
left = "a"
right = "d"
spell1 = " "
spell2 = "w"
spell3 = "s"
spell4 = "q"
spellKey =
{
    spell1,
    spell2,
    spell3,
    spell4
}

local saveDirectory = "saves"
love.filesystem.setIdentity(saveDirectory)
conf = loader:unpackIfExists(
{
    name = "conf",
    -- Screen settings
    screenWidth = 1600,
    screenHeight = 900,
    -- Camera settings
    ShouldCameraShake = true
})
-- Map settings
tileSize = 32
iconSize = tileSize * 2
worldXEnd = 10000 --TODO: should be calculated based on map.

-- Element colors
fireColor = {r = 240, b = 0, g = 70}
waterColor = {r = 40, b = 240, g = 70}
earthColor = {r = 100, b = 50, g = 120}
airColor = {r = 220, b = 255, g = 225}

-- Other colors
fontColor = {r=0,g=0,b=0}

-- Gesture grid settings
gridSize = 16
gridXOffset = conf.screenWidth / 4
gridYOffset = conf.screenHeight / 8

function love.conf(t)
    t.title = "Vaulted"
    t.window.width = conf.screenWidth
    t.window.height = conf.screenHeight
    t.modules.joystick = false
    t.vsync = false
    t.window.fullscreen = false
    t.identity = saveDirectory
end
