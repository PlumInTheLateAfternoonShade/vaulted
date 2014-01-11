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
local canonicalScreenWidth = 1600
local canonicalScreenHeight = 900

conf = loader:unpackIfExists(
{
    name = "conf",
    -- Screen settings
    screenWidth = canonicalScreenWidth,
    screenHeight = canonicalScreenHeight,
    -- Camera settings
    ShouldCameraShake = true
})
-- Map settings
tileSize = 32
iconSize = tileSize * 2
worldXEnd = 10000 --TODO: should be calculated based on map.

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
    t.window.resizable = true
    t.window.minwidth = 400
    t.window.minheight = 300
    t.modules.joystick = false
    t.vsync = false
    t.window.fullscreen = false
    t.identity = saveDirectory
end
