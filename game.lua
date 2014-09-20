local entitySystem = require('systems.entitySystem')
local positionSystem = require('systems.positionSystem') --TODO DEL
local objectFactory = require('systems.objectFactory')
require('utils')
local Point = require 'geometry.Point'
local loader = require 'loader'

heroId = nil -- Global for entity id of hero. Hopefully remove some day.

local Game = require 'class'
{
    name = 'Game',
    function(self, shouldLoadHero)
        love.physics.setMeter(conf.tileSize)
        objectFactory.init()
        -- Add hero to world
        local heroSpellBook = nil
        if shouldLoadHero then
            heroSpellBook = loader:unpack("SpellBook")
            local componentTables = heroSpellBook[1].componentTables
            if not componentTables then
                print("nil spell book")
            else
                for i = 1, #componentTables do
                    for j = 1, #componentTables[i] do
                        local comp = componentTables[i][j]
                        assert(comp)
                        print("class: "..comp.class.name.." fU: "..tostring(comp.firstUpdate))
                        if comp.firstUpdate == false then
                            comp.firstUpdate = true
                        end
                        print("fU2: "..tostring(comp.firstUpdate))
                    end
                end
            end
        end
        heroId = objectFactory.createPlayer({
        points = {
            Point(0, 0),
            Point(0, conf.tileSize*2),
            Point(conf.tileSize, conf.tileSize*2),
            Point(conf.tileSize, 0)
        },
        center = Point(200, -550)}, heroSpellBook)
        -- init debug vars
        self.fps = 0
        self.secondCount = 1.1

        self.shouldSave = true
    end
}
Game:inherit(require 'state')

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
end

function Game:draw()
    entitySystem:draw(false)

    setColorInverted(conf.fontColor)
    -- Debug
    local heroCenter = positionSystem:getCenter(heroId)
    local vx, vy = require 'systems.physicsSystem':get(heroId).body:getLinearVelocity()
    love.graphics.print(string.format("x: %d y: %d vx: %d vy: %d", heroCenter.x, heroCenter.y, vx, vy),
    conf.screenWidth * 0.77, conf.screenHeight * 0.1)
    -- draw the FPS counter
    love.graphics.print(string.format("FPS: %d", self.fps),
    conf.screenWidth * 0.9, conf.screenHeight * 0.2)
end

function Game:keypressed(key)
    entitySystem:keyPressed(key)
end

function Game:keyreleased(key)
    entitySystem:keyReleased(key)
end

return Game
