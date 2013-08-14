game = {}

require('camera')
require('spellBook')
require('utils')
require('gestures')
local loader = require "AdvTiledLoader/Loader"
-- set the path to the Tiled map files
loader.path = "maps/"
local HC = require "HardonCollider"

local hero
local collider
local allSolidTiles

function game.load()
    -- load the level and bind to variable map
    map = loader.load("level.tmx")
    map.tileWidth = 16
    map.widthInPixels = map.tileWidth * map.width
    -- load HardonCollider, set callback to on_collide and size of 100
    collider = HC(100, on_collide)

    -- find all the tiles that we can collide with
    allSolidTiles = findSolidTiles(map)

    -- set up the hero object, set him to position 32, 32
    setupHero(32,32)

    -- init debug vars
    game.fps = 0
    game.secondCount = 1.1

    game.maxXp = 2000
end

function game.update(dt)

    -- update the FPS counter
    game.secondCount = game.secondCount + dt
    if game.secondCount > 1 then
        game.secondCount = game.secondCount - 1
        game.fps = 1 / dt
    end

    updateHero(dt)

    -- update the collision detection
    collider:update(dt)
end

function game.draw()

    -- scale everything 1x
    love.graphics.scale(1, 1)
    camera:set()
    -- draw the level
    map:draw()

    -- draw the hero as a rectangle
    hero:draw("fill")
    camera:unset()

    -- draw the xp bar
    game.drawXpBar()

    -- draw the FPS counter
    love.graphics.print("FPS: "..string.format("%d", game.fps),
    screenWidth - 100, 50)
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

function setupHero(x,y)
    -- physical properties
    hero = collider:addRectangle(x,y,16,16)
    hero.size = 16
    hero.XVeloc = 0
    hero.XAccel = 0
    hero.YAccel = 9.8
    hero.YVeloc = 0
    hero.MaxXSpeed = 300
    hero.MaxYSpeed = 3000

    -- mental properties
    hero.vocab = 0 --placeholder
    game.vocab = 100 --placeholder
    hero.xp = game.getHeroXp()

    --	hero.img = love.graphics.newImage("img/hero.png")
end

-------------------------------
-- Key input handling functions
-------------------------------

function game.keypressed(key)
    if key == right then
        hero.XVeloc = 0
        hero.XAccel = 10
    elseif key == left then
        hero.XVeloc = 0
        hero.XAccel = -10
    elseif spellBook.keyMatch(key) then
        spellBook[spellBook.i]:cast(1, hero)
    elseif key == openMenu then
        updateState("back to main menu")
    elseif key == gesture then
        updateState("gestures")
    end
end

function game.keyreleased(key)
    if (key == right and hero.XAccel == 10)
        or (key == left and hero.XAccel == -10) then
        hero.XAccel = 0
        hero.XVeloc = 0
    end
end

--------------
-- XP Functions
--------------

function game.getHeroXp()
    return ((hero:center() / map.widthInPixels) + (hero.vocab / game.vocab))
           * 1000
end

function game.drawXpBar()
    red, green, blue = love.graphics.getColor()
    setColor({r=100, g=100, b=100})
    love.graphics.rectangle("fill", 0, screenHeight - 75, 
                            screenWidth*(game.getHeroXp() / game.maxXp), 50)
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
                local ctile = collider:addRectangle((tileX-1)*16,(tileY-1)*16,16,16)
                ctile.type = "tile"
                collider:addToGroup("tiles", ctile)
                collider:setPassive(ctile)
                table.insert(collidable_tiles, ctile)
            end
        end
    end
    return collidable_tiles
end
