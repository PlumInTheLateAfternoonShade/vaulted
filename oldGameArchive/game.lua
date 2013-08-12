game = {}

require('camera')
local loader = require 'AdvTiledLoader/Loader'
loader.path = 'maps/'
local HC = require 'HardonCollider'

local hero
local collider
local allSolidTiles

function game.load()
    -- hero initiliazition
    hero.size = imgs["player"]:getWidth()
    hero.X = 100
    hero.Y = 800
    hero.XYVeloc = 0
    hero.XYAccel = 0
    hero.MaxXYSpeed = 300
    
    -- debug initialization
    game.fps = 0
    game.secondCount = 0

    -- load level
    map = loader.load("level.tmx")

    -- load HardonCollider
    collider = HC(100, on_collide)

    -- find solid tiles
    allSolidTiles = findSolidTiles(map)
end

function game.draw()
    camera:set()
    map:draw()
    love.graphics.print("FPS: "..string.format("%d", game.fps), 1500, 50)
    -- draw hero
    love.graphics.draw(imgs["player"], hero.X, hero.Y, 0, 1, 1,
                        hero.size/2, hero.size/2)
    camera:unset()
end

function game.update(dt)
    game.secondCount = game.secondCount + dt
    if game.secondCount > 1 then
        game.secondCount = game.secondCount - 1
        game.fps = 1 / dt
    end
    -- update hero x position
    hero.XYVeloc = limitedInc(hero.XYVeloc, hero.XYAccel,
                                    hero.MaxXYSpeed)
    hero.X = hero.X + hero.XYVeloc*dt
    camera.x = hero.X - hero.size * 8

    collider:update(dt)
end

function game.keypressed(key)
    if key == right then
        hero.XYVeloc = 0
        hero.XYAccel = 10
    elseif key == left then
        hero.XYVeloc = 0
        hero.XYAccel = -10
    elseif key == openMenu then
        updateState("back to main menu")
    end
end

function game.keyreleased(key)
    if (key == right and hero.XYAccel == 10)
    or (key == left and hero.XYAccel == -10) then
        hero.XYAccel = 0
        hero.XYVeloc = 0
    end
end

function limitedInc(var, inc, limit)
   result = var + inc
   return math.max(math.min(result, limit), -limit)
end

function findSolidTiles(map)
    local collidable_tiles = {}
    --get the layer that the tiles are on by name
    local layer = map.tl["ground"]

    for tileX=1,map.width do
        for tileY=1,map.height do

            local tile

            if layer.tileData[tileY] then
                tile = map.tiles[layer.tileData[tileY][tileX]]
            end

            if tile and tile.properties.solid then
                local ctile = collider:addRectangle((tileX-1)*16, (tileY-1)*16,
                                                     16,16)
                ctile.type = "tile"
                collider:addToGroup("tiles", ctile)
                collider:setPassive(ctile)
                table.insert(collidable_tiles, ctile)
            end
        end
    end

    return collidable_tiles
end
