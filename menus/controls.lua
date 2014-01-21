-- Provides the UI for making new spell gestures.
require 'utils'
require 'lib.LoveFrames'
local keys = require 'keys'
local inputSystem = require 'systems.inputSystem'
local input = require 'components.input'

local Controls = require 'class'
{
    name = 'Controls',
    function(self)
        self:initGUI()
        loveframes.SetState("controls")
    end
}
Controls:inherit(require 'state')

function Controls:draw()
    -- Draw the buttons
    loveframes.draw()
    -- Draw the cursor
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    setColor({r = 255, g = 255, b = 255})
    love.graphics.circle("fill", mouseX, mouseY, 10, 100)
end

function Controls:update(dt)
    loveframes.update(dt)
end

local function returnToSettings()
    local heroInput = inputSystem:get(heroId)
    if heroInput then
        input.syncWithKeys(heroInput)
    end
    loveframes.SetState("none")
    updateState("settings")
end

function Controls:keypressed(key)
    if key == keys.confirm or key == keys.openMenu then
        returnToSettings()
    end
end

function Controls:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function Controls:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

local function createButton(string, x, y, func)
    local button = loveframes.Create("button")
    button:SetWidth(conf.screenHeight / 6)
    button:SetHeight(conf.screenHeight / 24)
    button:SetPos(x, y)
    button:SetText(string)
    button:SetState("controls")
    button.OnClick = func
end

local function createKeyButton(purpose, key, ...)
    createButton(purpose..": "..key, ...)
end

function Controls:initGUI()
    local step = conf.screenHeight / 12
    local i = 0
    for purpose, key in pairs(keys) do
        if purpose == "spells" then
            for index, k in ipairs(key) do
                local x = math.floor(i/10)*2*step + step
                local y = (i % 10)*step + 2*step
                i = i + 1
                createKeyButton("cast spell "..index, k, x, y, function () updateState("controlSet", index, k) end)
            end
        else
            local x = math.floor(i/10)*2*step + step
            local y = (i % 10)*step + 2*step
            i = i + 1
            createKeyButton(purpose, key, x, y, function () updateState("controlSet", purpose, key) end)
        end
    end
    createButton("back to settings", conf.screenWidth*0.8, conf.screenHeight*0.8, returnToSettings)
end

return Controls
