game = {}

function game.load()
    -- player initiliazition
    game.playerSize = imgs["player"]:getWidth()
    game.playerX = 100
    game.playerY = 800
    game.playerXYVeloc = 0
    game.playerXYAccel = 0
    game.playerMaxXYSpeed = 300
end

function game.draw()   
    love.graphics.print('Hello World!', 400, 300)
    -- draw player
    love.graphics.draw(imgs["player"], game.playerX, game.playerY, 0, 1, 1,
                        game.playerSize/2, game.playerSize/2)
end

function game.update(dt)
    -- update player x position
    game.playerXYVeloc = limitedInc(game.playerXYVeloc, game.playerXYAccel,
                                    game.playerMaxXYSpeed)
    game.playerX = game.playerX + game.playerXYVeloc*dt
end

function game.keypressed(key)
    if key == "right" then
        game.playerXYVeloc = 0
        game.playerXYAccel = 10
    elseif key == "left" then
        game.playerXYVeloc = 0
        game.playerXYAccel = -10
    end
end

function game.keyreleased(key)
    if key == "right" or key == "left" then
        game.playerXYAccel = 0
        game.playerXYVeloc = 0
    end
end

function limitedInc(var, inc, limit)
   result = var + inc
   return math.max(math.min(result, limit), -limit)
end
