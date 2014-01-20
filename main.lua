local Game = require('game')
local Menu = require('menus.menu')
local Settings = require('menus.settings')
local Graphics = require('menus.graphics')
local Resolution = require('menus.resolution')
local Gestures = require('gestures')
local SaveAndExit = require('saveAndExit')
local state = Menu()
local savedGame = nil
-- TODO - Refactor to pass in old state and return new one instead
-- of mutating global state.
local stateInitializers =
{
    ["continue"] = function()
        if savedGame == nil then
            state = Game(true)
        else
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

    -- set some graphics settings
    love.graphics.setLineStyle('rough')
end

function love.resize(w, h)
    conf.screenWidth = w
    conf.screenHeight = h
    -- TODO Set camera's scaleY and scaleX properly
    local sc = conf.screenHeight / conf.canonicalScreenHeight
    love.graphics.scale(sc, sc)
    print(("Window resized to width: %d and height: %d. Scale: %3.2f"):format(w, h, sc))
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
    -- It's more convenient to have the word space
    -- so we can draw it without ifs.
    if key == " " then
        key = "space"
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
    -- TODO Attribute. This is not mine.
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
