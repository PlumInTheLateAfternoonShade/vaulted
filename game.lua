local entitySystem = require('systems.entitySystem')
local positionSystem = require('systems.positionSystem') --TODO DEL
local objectFactory = require('systems.objectFactory')
local State = require('state')
local Camera = require('camera')
require('utils')
local Gestures = require('gestures')
local UI = require('ui')
local Hero = require('actors.hero')
local Point = require('geometry.Point')
local tLoader = require('loader')
local loader = require "lib/AdvTiledLoader/Loader"
-- set the path to the Tiled map files
loader.path = "maps/"
local SpellBook = require('spellBook')
local VisibleIcons = require('spells.visibleIcons')

local world
objects = {} -- a table of all collidable objects in the world
rayCastStack = {}
local visibleIcons -- The spell icons made by gestures.
local visuals -- Visible effects in the world, like bolts of lightning.
local camera -- Need this static for now because the callback funcs need it.
local heroId

local Game = Class
{
    name = 'Game',
    function(self, shouldLoadHero)
        visibleIcons = VisibleIcons()
        visuals = {}
        objects = {}
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
        center = Point(200, -550)})
        --local loadedHero
        --if shouldLoadHero then
        --    loadedHero = tLoader:unpack("Hero")
        --end
        --hero = Hero(world, nil, Point(200, -550), loadedHero)
        --table.insert(objects, hero)
        -- load the level and bind to variable map
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
        visibleIcons:update()
        -- update the FPS counter
        self.fps = love.timer.getFPS()
    end
    entitySystem:update(dt)

    for i = #objects, 1, -1 do
        objects[i]:update(dt)
    end
    for i = #visuals, 1, -1 do
        if not visuals[i]:update(dt) then
            table.remove(visuals, i)
        end
    end

    while #rayCastStack > 0 do
        local r = rayCastStack[#rayCastStack]
        world:rayCast(r.x1, r.y1, r.x2, r.y2, r.func)
        table.remove(rayCastStack, #rayCastStack)
    end
    local heroCenter = positionSystem:getCenter(heroId)
    camera:setAdjPosition(heroCenter.x, heroCenter.y, dt)
end

function Game:draw()
    --camera:set()
    entitySystem:draw()
    --[[ draw all visible spell icons
    --[[visibleIcons:draw()
    -- draw all visual effects
    for i = 1, #visuals do
        visuals[i]:draw()
    end
    setColor({r=255, g=255, b=255})
    -- set the tile map's draw range so we only draw the tiles on screen
    self.map:setDrawRange(camera.x, camera.y, conf.screenWidth, conf.screenHeight)
    -- draw the tile map
    self.map:draw()

    camera:unset()]]--
    -- draw the ui
    --UI:draw() TODO Reimplement

    setColorInverted(fontColor)
    -- draw the FPS counter
    love.graphics.print("FPS: "..string.format("%d", self.fps),
    conf.screenWidth * 0.9, conf.screenHeight * 0.1)
end

-------------------------------
-- Key input handling functions
-------------------------------

function Game:keypressed(key)
    entitySystem:keyPressed(key)
    --[[if key == right then
        hero:setWalkingRight()
    elseif key == left then
        hero:setWalkingLeft()
    elseif hero.spellBook:keyMatch(key) then
        local icon, vis = hero.spellBook[hero.spellBook.i]:cast(world, hero)
        if icon then
            visibleIcons:add(icon)
        end
        if vis then
            for i = 1, #vis do
                table.insert(visuals, vis[i])
            end
        end]]--
    --[[elseif key == openMenu then
        updateState("back to main menu")
    elseif key == gesture then
        updateState("gestures")
    end]]--
end

function Game:keyreleased(key)
    entitySystem:keyReleased(key)
    --[[if (key == right and hero:isWalkingRight())
        or (key == left and hero:isWalkingLeft()) then
        hero:setStanding()
    end]]--
end

--------------

function limitedInc(var, inc, limit)
    result = var + inc
    return math.max(math.min(result, limit), -limit)
end

return Game
