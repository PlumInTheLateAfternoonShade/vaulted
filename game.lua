require('state')
require('camera')
require('spellBook')
require('utils')
require('gestures')
require('actors.hero')
require('geometry.Point')
local visibleIcons = {}
local loader = require "AdvTiledLoader/Loader"
-- set the path to the Tiled map files
loader.path = "maps/"
local HC = require "HardonCollider"
local Class = require 'HardonCollider.class'

local hero
local collider
local allSolidTiles

local camera
local world

Game = Class
{
    name = 'Game',
    function(self)
        self.groundFriction = 0.5
        love.physics.setMeter(tileSize)
        world = love.physics.newWorld(0, 50*tileSize, true)
        world:setCallbacks(beginContact, endContact, preSolve,
        postSolve)
        objects = {} -- a table of all collidable objects in the world
        objects.ground = {}
        objects.ground.body = love.physics.newBody(world, screenWidth/2,
        screenHeight - 50/2)
        objects.ground.shape = love.physics.newRectangleShape(screenWidth, 50)
        objects.ground.fixture = love.physics.newFixture(objects.ground.body,
        objects.ground.shape)
        objects.ground.fixture:setFriction(self.groundFriction)
        objects.ground.fixture:setUserData("Ground")
        hero = Hero(world, Point(200, 550), tileSize, tileSize*3)
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
    hero:update(dt)
    world:update(dt)
end

function Game:draw()
    camera.x = hero.body:getX() - screenWidth/(2*camera.scaleX)
    camera.y = hero.body:getY() - screenHeight/(2*camera.scaleY)
    camera:set()

    love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
    love.graphics.polygon("fill", 
    objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
    -- draw the level
    --map:draw()
    -- draw the hero as a rectangle
    hero:draw()
    -- draw all visible spell icons
    visibleIcons:draw()
    camera:unset()
    -- draw the xp bar
    self.drawXpBar()
    -- draw the FPS counter
    love.graphics.print("FPS: "..string.format("%d", self.fps),
    screenWidth * 0.9375, screenHeight * 0.0625)

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
    setRighting(a, b, true)
end

function endContact(a, b, coll)
    setRighting(a, b, false)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll)
end

function setRighting(a, b, value)
    local userData = {[a:getUserData()] = a, [b:getUserData()] = b}
    local actor = userData["Actor"]
    local ground = userData["Ground"]
    if actor ~= nil and ground ~= nil then
        hero.righting = value --TODO horrifically wrong.
        hero.body:setFixedRotation(value)
    end
end

function on_collide(dt, shape_a, shape_b, mtv_x, mtv_y)
    -- seperate collision function for entities
    collideHeroWithTile(dt, shape_a, shape_b, mtv_x, mtv_y)
end

function collideHeroWithTile(dt, shape_a, shape_b, mtv_x, mtv_y)
    -- sort out which one our hero shape is
    local hero_shape, tileshape
    if shape_a == hero and shape_b.type == "tile" then
        hero_shape = shape_a
    elseif shape_b == her and shape_a.type == "tile" then
        hero_shape = shape_b
    else
        -- none of the two shapes is a tile, return to upper function
        return
    end
    -- why not in one function call? because we will need to differentiate between the axis later
    hero_shape:move(mtv_x, 0)
    hero_shape:move(0, mtv_y)
    hero.YVeloc = 0 -- TODO wrong.
end

function Game:setupHero(x,y)
    -- physical properties
    hero = collider:addRectangle(x, y, 16, 16)
    hero.size = 16
    hero.XVeloc = 0
    hero.XAccel = 0
    hero.YAccel = 9.8
    hero.YVeloc = 0
    hero.MaxXSpeed = 300
    hero.MaxYSpeed = 3000

    -- mental properties
    hero.farthestX = 0
    hero.damage = 0
    hero.xp = self:getHeroXp()
    --	hero.img = love.graphics.newImage("img/hero.png")
end

-------------------------------
-- Key input handling functions
-------------------------------

function Game:keypressed(key)
    if key == right then
        hero:setWalkingRight()
    elseif key == left then
        hero:setWalkingLeft()
    elseif spellBook.keyMatch(key) then
        local icon = spellBook[spellBook.i]:cast(world, hero)
        table.insert(visibleIcons, icon)
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
-- XP Functions
--------------

function Game:getHeroXp()
    hero.farthestX = math.max(hero:center(), hero.farthestX)
    hero.xp = hero.farthestX / map.widthInPixels * 2000 - hero.damage
    --* self.maxXp TODO??bug
    return hero.xp
end

function Game:drawXpBar()
    red, green, blue = love.graphics.getColor()
    setColor({r=100, g=100, b=100})
    --TODO!!
    --   love.graphics.rectangle("fill", 0, screenHeight - 75, 
    --   screenWidth*(self:getHeroXp() / self.maxXp), 50)
    setColor({r=red, g=green, b=blue})
end

--------------

function updateHero(dt)
    hero.XVeloc = limitedInc(hero.XVeloc, hero.XAccel, hero.MaxXSpeed)
    hero.YVeloc = limitedInc(hero.YVeloc, hero.YAccel, hero.MaxYSpeed)
    hero:move(hero.XVeloc*dt, hero.YVeloc*dt)
    camera.x = hero:center() - hero.size * 8
end

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

function visibleIcons:update()
    -- Remove any visible icons which have persisted beyond their lifetimes.
    for i = #visibleIcons, 1, -1 do
        v = visibleIcons[i]
        if os.clock() >= v.dateBorn + v.maxAge then
            table.remove(visibleIcons, i)
        end
    end
end

function visibleIcons:draw()
    -- Draw each visible icon
    for i = 1, #visibleIcons do
        visibleIcons[i]:draw()
    end
end
