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
local HC = require "HardonCollider"
local Class = require 'HardonCollider.class'
local SpellBook = require('spellBook')
local VisibleIcons = require('spells.visibleIcons')

local collider
local allSolidTiles

local camera
local world
objects = {} -- a table of all collidable objects in the world
rayCastStack = {}
local visibleIcons

local Game = Class
{
    name = 'Game',
    function(self, shouldLoadHero)
        visibleIcons = VisibleIcons()
        objects = {}
        love.physics.setMeter(tileSize)
        world = love.physics.newWorld(0, 50*tileSize, true)
        world:setCallbacks(beginContact, endContact, preSolve,
        postSolve)
        local groundPoints =
        {
            Point(-tileSize*50, -tileSize),
            Point(-tileSize*50, tileSize),
            Point(tileSize*50, tileSize),
            Point(tileSize*50, -tileSize)
        }
        local ground = Ground(world, groundPoints, Point(tileSize*25, 0),
        {r = 150, g = 75, b = 75})
        table.insert(objects, ground)
        local loadedHero
        if shouldLoadHero then
            loadedHero = tLoader:unpack("Hero")
        end
        hero = Hero(world, nil, Point(200, -550), loadedHero)
        table.insert(objects, hero)
        -- load the level and bind to variable map
        --[[map = loader.load("level.tmx")
        map.tileWidth = tileSize
        map.widthInPixels = map.tileWidth * map.width
        - load HardonCollider, set callback to on_collide and size of 100
        collider = HC(100, on_collide)

        -- find all the tiles that we can collide with
        allSolidTiles = findSolidTiles(map)

        -- set up the hero object, set him to position 32, 32
        self:setupHero(32, 32)]]--

        -- init debug vars
        self.fps = 0
        self.secondCount = 1.1

        self.maxXp = 2000

        -- init camera
        camera = Camera()
        camera:scale(0.25, 0.25)
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
        self.fps = 1 / dt
    end
    world:update(dt)
    for i = #objects, 1, -1 do
        objects[i]:update(dt)
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

    love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
    for i = 1, #objects do
        -- draw the objects as rectangles
        objects[i]:draw()
    end
    -- draw all visible spell icons
    visibleIcons:draw()

    -- Effect debug
    --[[if hero.spellBook[1] ~= nil then
    if hero.spellBook[1].regions[1] ~= nil then
    love.graphics.print("Here", hero.spellBook[1].regions[1].effect.x, hero.spellBook[1].regions[1].effect.y)
    end
    end]]--


    camera:unset()
    -- draw the ui
    UI:draw()

    setColorInverted(fontColor)
    -- draw the FPS counter
    love.graphics.print("FPS: "..string.format("%d", self.fps),
    screenWidth * 0.9375, screenHeight * 0.0625)

    -- debug prints
    local vX, vY = hero.body:getLinearVelocity()
    love.graphics.print(string.format("vX: %.2f vY: %.2f", vX, vY),
    screenWidth*0.7, screenHeight*0.7)

    love.graphics.print("WrappedAngle: "
    ..string.format("%.2f", hero:getWrappedAngle()),
    screenWidth * 0.6, screenHeight * 0.6)
    love.graphics.print("AngVel: "
    ..string.format("%.2f", hero.body:getAngularVelocity()).." IsFixed: "
    ..tostring(hero.body:isFixedRotation()),
    screenWidth * 0.6, screenHeight * 0.4)
    love.graphics.print("Mass: "..string.format("%.2f", hero.body:getMass()),
    screenWidth * 0.4, screenHeight * 0.4)
end

function beginContact(a, b, coll)
    -- If the force of the impact is high enough, shake the screen.
    camera:shake(a:getBody(), b:getBody(), coll)
    -- Handle the collision of the individual CollidableObjects.
    local done = 0
    local aIndex, bIndex
    for i = #objects, 1, -1 do
        if objects[i].fixture == a then
            aIndex = i
            done = done + 1
            if done == 2 then
                break
            end
        elseif objects[i].fixture == b then
            bIndex = i
            done = done + 1
            if done == 2 then
                break
            end
        end
    end
    objects[aIndex]:beginCollision(objects[bIndex], coll, world)
    objects[bIndex]:beginCollision(objects[aIndex], coll, world)
end

function endContact(a, b, coll)
    local done = 0
    for i = 1, #objects do
        if objects[i].fixture == a then
            objects[i]:endCollision(b, coll, world)
            done = done + 1
            if done == 2 then
                break
            end
        elseif objects[i].fixture == b then
            objects[i]:endCollision(a, coll, world)
            done = done + 1
            if done == 2 then
                break
            end
        end
    end
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll)
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
        local icon = hero.spellBook[hero.spellBook.i]:cast(world, hero)
        if icon then
            visibleIcons:add(icon)
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

function findSolidTiles(map)
    local collidable_tiles = {}
    -- get the layer that the tiles are on by name
    local layer = map.tl["ground"]


    for tileX=1,map.width do
        for tileY=1,map.height do

            local tile

            if layer.tileData[tileY] then
                tile = map.tiles[layer.tileData[tileY][tileX]]
            end

            if tile and tile.properties.solid then
                local ctile = collider:addRectangle((tileX-1)*tileSize,
                (tileY-1)*tileSize,
                tileSize, tileSize)
                ctile.type = "tile"
                collider:addToGroup("tiles", ctile)
                collider:setPassive(ctile)
                table.insert(collidable_tiles, ctile)
            end
        end
    end
    return collidable_tiles
end

return Game
