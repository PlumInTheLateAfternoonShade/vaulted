game = {}

require('camera')

function game.load()
    -- player initiliazition
    game.playerSize = imgs["player"]:getWidth()
    game.playerX = 100
    game.playerY = 800
    game.playerXYVeloc = 0
    game.playerXYAccel = 0
    game.playerMaxXYSpeed = 300
    game.fps = 0
    game.secondCount = 0
end

function game.draw()
    camera:set()
    love.graphics.print("FPS: "..string.format("%d", game.fps), 1500, 50)
    -- draw player
    love.graphics.draw(imgs["player"], game.playerX, game.playerY, 0, 1, 1,
                        game.playerSize/2, game.playerSize/2)
    camera:unset()
end

function game.update(dt)
    game.secondCount = game.secondCount + dt
    if game.secondCount > 1 then
        game.secondCount = game.secondCount - 1
        game.fps = 1 / dt
    end
    -- update player x position
    game.playerXYVeloc = limitedInc(game.playerXYVeloc, game.playerXYAccel,
                                    game.playerMaxXYSpeed)
    game.playerX = game.playerX + game.playerXYVeloc*dt
    camera.x = game.playerX - game.playerSize * 8
end

function game.keypressed(key)
    if key == right then
        game.playerXYVeloc = 0
        game.playerXYAccel = 10
    elseif key == left then
        game.playerXYVeloc = 0
        game.playerXYAccel = -10
    elseif key == openMenu then
        updateState("back to main menu")
    end
end

function game.keyreleased(key)
    if (key == right and game.playerXYAccel == 10)
    or (key == left and game.playerXYAccel == -10) then
        game.playerXYAccel = 0
        game.playerXYVeloc = 0
    end
end

function limitedInc(var, inc, limit)
   result = var + inc
   return math.max(math.min(result, limit), -limit)
end
