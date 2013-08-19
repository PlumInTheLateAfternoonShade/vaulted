require('game')
require('menus.menu')
require('menus.settings')
require('gestures')
require('lib.deepcopy.deepcopy')
if ShouldProfile then
    local ProFi = require 'ProFi'
end
local state = Menu()
main = {}

function love.load()
    if ShouldProfile then
        -- prof only. Start the profiler.
        ProFi:start()
    end

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

    -- set some graphics settings
    love.graphics.setLineStyle('rough')
end

function love.draw()
    -- call the state's draw function
    state:draw()
end

function love.update(dt)
    -- call the state's update function
    state:update(dt)
    --[[elseif main.state == "saveAndExit" then
    if ShouldProfile then
    -- prof only
    ProFi:stop()
    ProFi:writeReport('profile.txt')
    end
    os.exit()]]--
    --end
end

function love.keypressed(key)
    -- first check for game-wide overrides
    if key == "`" then
        debug.debug()
    elseif key == 'return' and love.keyboard.isDown('lalt', 'ralt') then
        love.graphics.toggleFullscreen()
        -- call the state's keypressed function
    end
    state:keypressed(key)
end

function love.keyreleased(key)
    -- call the state's keyreleased function
    state:keyreleased(key)
end

function love.mousepressed(button, x, y)
    state:mousepressed(button, x, y)
end

function love.mousereleased(button, x, y)
    state:mousereleased(button, x, y)
end

function updateState(choice)
    if choice == "continue" then
        if savedGame == nil then
            state = Game()
        else
            state = savedGame
        end
    elseif choice == "new game" then
        state = Game()
    elseif choice == "exit" then
        state = SaveAndExit()
    elseif choice == "settings" then
        state = Settings()
    elseif choice == "back to main menu" then
        savedGame = objectDeepcopy(state)
        state = Menu()
    elseif choice == "gestures" then
        savedGame = objectDeepcopy(state)
        state = Gestures()
    end
end

function objectDeepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, _copy(getmetatable(object)))
    end
    return _copy(object)
end
