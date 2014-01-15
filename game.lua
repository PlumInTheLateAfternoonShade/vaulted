local entitySystem = require('systems.entitySystem')
local positionSystem = require('systems.positionSystem') --TODO DEL
local objectFactory = require('systems.objectFactory')
local State = require('state')
local Camera = require('camera')
require('utils')
local Point = require('geometry.Point')
local tLoader = require('loader')
local loader = require "lib/AdvTiledLoader/Loader"
-- set the path to the Tiled map files
loader.path = "maps/"

local world
local camera -- Need this static for now because the callback funcs need it.

local Game = Class
{
    name = 'Game',
    function(self, shouldLoadHero)
        love.physics.setMeter(tileSize)
        world = love.physics.newWorld(0, 50*tileSize, true)
        -- init camera
        camera = Camera()
        self.map = loader.load("level1.tmx")
        self.map.tileWidth = tileSize
        self.map.widthInPixels = self.map.tileWidth * self.map.width
        objectFactory.init(world, camera, self.map) -- TODO world inside entitySys
        heroId = objectFactory.createPlayer({
        points = {
            Point(0, 0),
            Point(0, tileSize*2),
            Point(tileSize, tileSize*2),
            Point(tileSize, 0)
        },
        center = Point(200, -550)}, tLoader:unpack("spellBook"))
        self.map:addToWorld()
        -- init debug vars
        self.fps = 0
        self.secondCount = 1.1

        self.maxXp = 2000

        self.shouldSave = true
    end
}
Game:inherit(State)

function Game:update(dt)
    self.secondCount = self.secondCount + dt
    if self.secondCount > 1 then
        -- updates which only have to happen once in a while
        -- get shoved in here to reduce performance impact.
        self.secondCount = self.secondCount - 1
        -- update the FPS counter
        self.fps = love.timer.getFPS()
    end
    entitySystem:update(dt)
    local heroCenter = positionSystem:getCenter(heroId)
    camera:setAdjPosition(heroCenter.x, heroCenter.y, dt)
end

function Game:draw()
    entitySystem:draw(false)

    setColorInverted(fontColor)
    -- Debug
    local heroCenter = positionSystem:getCenter(heroId)
    love.graphics.print(string.format("x: %d y: %d", heroCenter.x, heroCenter.y),
    conf.screenWidth * 0.8, conf.screenHeight * 0.1)
    -- draw the FPS counter
    love.graphics.print(string.format("FPS: %d", self.fps),
    conf.screenWidth * 0.9, conf.screenHeight * 0.2)
end

-------------------------------
-- Key input handling functions
-------------------------------

function Game:keypressed(key)
    entitySystem:keyPressed(key)
end

function Game:keyreleased(key)
    entitySystem:keyReleased(key)
end

function limitedInc(var, inc, limit)
    result = var + inc
    return math.max(math.min(result, limit), -limit)
end

return Game
