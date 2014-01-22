ShouldProfile = true
require 'lib.luafun.fun' ()
local tempLoader = require 'lib.AdvTiledLoader.Loader'
require 'class'
if ShouldProfile then
    ProFi = require 'lib.ProFi'
end
require 'lib.strict'
local loader = require 'loader'

local saveDirectory = "vaulted"
love.filesystem.setIdentity(saveDirectory)
local canonicalScreenWidth = 1600
local canonicalScreenHeight = 900

conf = loader:unpackIfExists(
{
    name = "conf",
    -- Screen settings
    screenWidth = canonicalScreenWidth,
    screenHeight = canonicalScreenHeight,
    canonicalScreenWidth = canonicalScreenWidth,
    canonicalScreenHeight = canonicalScreenHeight,
    -- Camera settings
    ShouldCameraShake = true,
    -- Map settings
    tileSize = 32,
    iconSize = 64,
    worldXEnd = 10000, --TODO: should be calculated based on map.
    -- Colors
    fontColor = {r=0,g=0,b=0},
    -- Game Scale
    scale = 1,
})

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
