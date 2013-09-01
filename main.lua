ShouldProfile = false
local Game = require('game')
local Menu = require('menus.menu')
local Settings = require('menus.settings')
local Gestures = require('gestures')
require('lib.deepcopy.deepcopy')
local SaveAndExit = require('saveAndExit')
if ShouldProfile then
    print('Got here')
    ProFi = require('ProFi')
end
local state = Menu()
local savedGame = Game(true)
main = {}

function love.load()
    if ShouldProfile then
        -- prof only. Start the profiler.
        print('Starting profiler.')
        ProFi:start()
    end

    math.randomseed(os.time())

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
            print('Returning to saved game.')
            state = savedGame
        end
    elseif choice == "new game" then
        state = Game()
    elseif choice == "exit" then
        SaveAndExit:close()
    elseif choice == "settings" then
        state = Settings()
    elseif choice == "back to main menu" then
        if state.shouldSave then
            savedGame = objectDeepcopy(state)
        end
        state = Menu()
    elseif choice == "gestures" then
        if state.shouldSave then
            savedGame = objectDeepcopy(state)
        end
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
