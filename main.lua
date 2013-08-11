require('game')

function love.load()
    -- load images
    imgNames = {"player"}
    imgs = {}
    for _,v in ipairs(imgNames) do
        imgs[v] = love.graphics.newImage("images/"..v..".gif")
    end
    
    -- set filter to nearest
    for _,v in pairs(imgs) do 
        v:setFilter("nearest", "nearest")
    end

    -- play menu audio TODO: move to menu.lua
    music = love.audio.newSource("music/music.ogg", "stream")
    music:setLooping(true)
    love.audio.play(music)

    -- set initial state
    state = "game"
    
    -- load the game
    game.load()
end

function love.draw()
    -- call the state's draw function
    if state == "game" then
        game.draw()
    elseif state == "menu" then
        menu.draw() --TODO not implemented
    end
end

function love.update(dt)
    -- call the state's update function
    if state == "game" then
        game.update(dt)
    elseif state == "menu" then
        menu.update(dt)
    end
end
    
function love.keypressed(key)
    -- call the state's keypressed function
    if state == "game" then
        game.keypressed(key)
    elseif state == "menu" then
        menu.keypressed(key)
    end
end

function love.keyreleased(key)
    -- call the state's keyreleased function
    if state == "game" then
        game.keyreleased(key)
    elseif state == "menu" then
        menu.keyreleased(key)
    end
end
