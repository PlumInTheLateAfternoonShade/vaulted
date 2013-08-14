require('game')
require('menu')
require('settings')
require('gestures')

main = {}

function love.load()
    -- hide the mouse
    love.mouse.setVisible(false)

    -- load images
    imgNames = {"player", "menuTitle"}
    imgs = {}
    for _,v in ipairs(imgNames) do
        imgs[v] = love.graphics.newImage("images/"..v..".gif")
    end
    
    -- set filter to nearest
    for _,v in pairs(imgs) do 
        v:setFilter("nearest", "nearest")
    end

    -- set initial main.state
    main.state = "menu"
    
    -- load the menu
    menu.load()
    -- load the game
    game.load()
end

function love.draw()
    -- call the main.state's draw function
    if main.state == "game" then
        game.draw()
    elseif main.state == "menu" then
        menu.draw()
    elseif main.state == "settings" then
        settings.draw()
    elseif main.state == "gestures" then
        gestures.draw()
    end
end

function love.update(dt)
    -- call the main.state's update function
    if main.state == "game" then
        game.update(dt)
    elseif main.state == "saveAndExit" then
        os.exit()
    end
end
    
function love.keypressed(key)
    -- first check for game-wide overrides
    if key == "`" then
        debug.debug()
    elseif key == 'return' and love.keyboard.isDown('lalt', 'ralt') then
        love.graphics.toggleFullscreen()
    -- call the main.state's keypressed function
    elseif main.state == "game" then
        game.keypressed(key)
    elseif main.state == "menu" then
        menu.keypressed(key)
    elseif main.state == "settings" then
        settings.keypressed(key)
    elseif main.state == "gestures" then
        gestures.keypressed(key)
    end
end

function love.keyreleased(key)
    -- call the main.state's keyreleased function
    if main.state == "game" then
        game.keyreleased(key)
    end
end

function updateState(choice)
    if choice == "continue" then
        main.state = "game"
    elseif choice == "exit" then
        main.state = "saveAndExit"
    elseif choice == "settings" then
        main.state = choice
        settings.load()
    elseif choice == "back to main menu" then
        main.state = "menu"
        menu.load()
    elseif choice == "gestures" then
        gestures.load()
        main.state = choice
    else
        main.state = choice
    end
end
