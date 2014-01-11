ShouldProfile = false
require "lib.luafun.fun" ()
Class = require('class')
local Game = require('game')
local Menu = require('menus.menu')
local Settings = require('menus.settings')
local Graphics = require('menus.graphics')
local Resolution = require('menus.resolution')
local Gestures = require('gestures')
require('lib.deepcopy.deepcopy')
local SaveAndExit = require('saveAndExit')
if ShouldProfile then
    print('Got here')
    ProFi = require('lib.ProFi')
end
local state = Menu()
local stateInitializers = {
    ["continue"] = function()
        if savedGame == nil then
            print('savedGame nil')
            state = Game(true)
        else
            print('Returning to saved game.')
            state = savedGame
        end
    end,
    ["new game"] = function()
        state = Game()
    end,
    ["exit"] = function()
        SaveAndExit:close()
    end,
    ["settings"] = function()
        state = Settings()
    end,
    ["graphics"] = function()
        state = Graphics()
    end,
    ["resolution"] = function()
        state = Resolution()
    end,
    ["back to main menu"] = function()
        if state.shouldSave then
            savedGame = objectDeepcopy(state)
        end
        state = Menu()
    end,
    ["gestures"] = function()
        if state.shouldSave then
            savedGame = objectDeepcopy(state)
        end
        state = Gestures()
    end
}

local savedGame = nil
main = {}

function love.load(args)
    if ShouldProfile then
        -- prof only. Start the profiler.
        print('Starting profiler.')
        ProFi:start()
    end
    
    if args[#args] == '-debug' then 
        require('mobdebug').start()
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

function love.resize(w, h)
    print(("Window resized to width: %d and height: %d."):format(w, h))
    conf.screenWidth = w
    conf.screenHeight = h
    camera.scaleY = 2
    --camera.scaleY = conf.canonicalScreenHeight
    --camera.scaleX = conf.canonicalScreenWidth
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
        toggleFullscreen()
    end
    -- call the state's keypressed function
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
    --TODO DEL
    print(choice)
    stateInitializers[choice]()
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

function toggleFullscreen()
    -- love.window.toggleFullscreen doesn't seem to be implemented yet.
    -- So use this until then.
    love.window.setFullscreen(not love.window.getFullscreen())
end
