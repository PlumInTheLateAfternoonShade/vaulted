local entitySystem = require('systems.entitySystem')
local objectFactory = require('systems.objectFactory')
local State = require('state')
local Camera = require('camera')
require('utils')
local Gestures = require('gestures')
local UI = require('ui')
local Ground = require('ground')
local Hero = require('actors.hero')
local Point = require('geometry.Point')
local tLoader = require('loader')
local loader = require "AdvTiledLoader/Loader"
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
        objectFactory.init(world, camera) -- TODO world inside entitySys
        local loadedHero
        if shouldLoadHero then
            loadedHero = tLoader:unpack("Hero")
        end
        hero = Hero(world, nil, Point(200, -550), loadedHero)
        table.insert(objects, hero)
        -- load the level and bind to variable map
        self.map = loader.load("level1.tmx")
        self.map.tileWidth = tileSize
        self.map.widthInPixels = self.map.tileWidth * self.map.width
        self.map:addToWorld(world, objects)
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
    world:update(dt)
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
    camera:setAdjPosition(hero.body:getX(), hero.body:getY(), dt)
end

function Game:draw()
    camera:set()
    entitySystem:draw()
    for i = 1, #objects do
        -- draw the objects as rectangles
        objects[i]:draw()
    end
    -- draw all visible spell icons
    visibleIcons:draw()
    -- draw all visual effects
    for i = 1, #visuals do
        visuals[i]:draw()
    end
    setColor({r=255, g=255, b=255})
    -- set the tile map's draw range so we only draw the tiles on screen
    self.map:setDrawRange(camera.x, camera.y, conf.screenWidth, conf.screenHeight)
    -- draw the tile map
    self.map:draw()

    camera:unset()
    -- draw the ui
    UI:draw()

    setColorInverted(fontColor)
    -- draw the FPS counter
    love.graphics.print("FPS: "..string.format("%d", self.fps),
    conf.screenWidth * 0.9, conf.screenHeight * 0.1)

    -- debug prints
    local vX, vY = hero.body:getLinearVelocity()
    love.graphics.print(string.format("vX: %.2f vY: %.2f", vX, vY),
    conf.screenWidth*0.7, conf.screenHeight*0.7)

    love.graphics.print("WrappedAngle: "
    ..string.format("%.2f", hero:getWrappedAngle()),
    conf.screenWidth * 0.6, conf.screenHeight * 0.6)
    love.graphics.print("AngVel: "
    ..string.format("%.2f", hero.body:getAngularVelocity()).." IsFixed: "
    ..tostring(hero.body:isFixedRotation()),
    conf.screenWidth * 0.6, conf.screenHeight * 0.4)
    love.graphics.print("Mass: "..string.format("%.2f", hero.body:getMass()),
    conf.screenWidth * 0.4, conf.screenHeight * 0.4)
end

-------------------------------
-- Key input handling functions
-------------------------------

function Game:keypressed(key)
    if key == right then
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
        end
    elseif key == openMenu then
        updateState("back to main menu")
    elseif key == gesture then
        updateState("gestures")
    end
end

function Game:keyreleased(key)
    if (key == right and hero:isWalkingRight())
        or (key == left and hero:isWalkingLeft()) then
        hero:setStanding()
    end
end

--------------

function limitedInc(var, inc, limit)
    result = var + inc
    return math.max(math.min(result, limit), -limit)
end

return Game
