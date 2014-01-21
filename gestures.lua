-- Provides the UI for making new spell gestures.
require 'utils'
require 'lib.LoveFrames'
local keys = require 'keys'
local img = require 'images.img'
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local spellBookSystem = require 'systems.spellBookSystem'
local positionSystem = require 'systems.positionSystem'
local runeSystem = require 'systems.runeSystem'
local forceSystem = require 'systems.forceSystem'
local entitySystem = require 'systems.entitySystem'
local objectFactory = require 'systems.objectFactory'
local element = require 'components.element'
local Gestures = require 'class'
{
    name = 'Gestures',
    function(self)
        -- Entity system preview setup
        self.firstGestureId = entitySystem.currId + 1
        self.spellBook = spellBookSystem:get(heroId)
        spellBookSystem:preview(heroId)
        -- The lines in the currently loaded drawable gesture
        self.lines = {}
        -- The currently selected rune
        self.rune = element:getName()
        -- Set up the drawing grid
        self:initGrid()
        -- Set up the GUI
        self:initGUI()
        self.drawPreviewLine = false
    end
}
Gestures:inherit(require 'state')

function Gestures:draw()
    -- Draw the world of gestures
    entitySystem:draw(true)
    -- Draw the grid of possible gesture points
    self:drawGrid()
    -- Draw each line in the current gesture
    self:drawLines()
    -- Draw the buttons
    loveframes.draw()
    -- Draw the cursor
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    element:setAsColor()
    love.graphics.circle("fill", mouseX, mouseY, 10, 100)
    -- Draw the preview line if necessary
    if self.drawPreviewLine then
        if self.rune == "force" then
            -- Draw the force arrow.
            forceSystem:drawPreview(self.startPoint, Point(mouseX, mouseY))
        else
            love.graphics.line(self.startPoint.x, self.startPoint.y, mouseX, mouseY)
        end
    end
end

function Gestures:update(dt)
    loveframes.update(dt)
end

function Gestures:drawGrid()
    local smallDotRad = 5
    local bigDotRad = 8
    setColor({r=255, g=255, b=255})
    for i = 1, self.gridSize do
        for j = 1, self.gridSize do
            local dotRad
            if self:isPlayerDot(i, j) then
                dotRad = bigDotRad
            else
                dotRad = smallDotRad
            end
            love.graphics.circle("fill", self.grid[i][j].x, 
            self.grid[i][j].y, dotRad, 100)
        end
    end
end

function Gestures:isPlayerDot(i, j)
    return i >= 8 and i <= 9 and j >= 8 and j <= 11
end

function Gestures:drawLines()
    love.graphics.setLineWidth(5)
    for i = 1, #self.lines do
        local line = self.lines[i]
        setColor(line.c)
        love.graphics.line(line.p0.x, line.p0.y, line.p1.x, line.p1.y)
    end
end


function Gestures:incrementSpell(amount)
    entitySystem:deleteAllInRange(self.firstGestureId, entitySystem.currId)
    self.firstGestureId = entitySystem.currId + 1
    spellBookSystem:inc(heroId, amount)
    spellBookSystem:preview(heroId)
end

function Gestures:incrementElement(amount)
    element:inc(amount)
    loveframes.SetState(element:getName())
    self.lines = {}
end

function Gestures:keypressed(key)
    if key == keys.up then
        self:incrementElement(-1)
    elseif key == keys.down then
        self:incrementElement()
    elseif key == keys.leftArrow then
        self:incrementSpell(-1)
    elseif key == keys.rightArrow then
        self:incrementSpell()
    elseif key == keys.confirm or key == keys.gesture then
        -- Remove all gesture graphics components from screen
        entitySystem:deleteAllInRange(self.firstGestureId, entitySystem.currId)
        loveframes.SetState("none")
        -- Go back to game.
        updateState("continue")
    end
end

function Gestures:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
    if self:inButtonSpace(x) then return end
    if button == "l" then
        --left mouse starts drawing a line
        self.startPoint = self:getNearestGridPoint(x, y)
        self.drawPreviewLine = true
    elseif button == "r" then
        --right mouse deletes the closest line or polygon
        local testId = positionSystem:testPointInRange(Point(x, y), self.firstGestureId, entitySystem.currId)
        if testId then
            entitySystem:delete(testId)
            spellBookSystem:deleteFromCurrent(heroId, testId)
        elseif #self.lines > 0 then
            self:deleteNearestLine(Point(x, y))
        end
    elseif button == "wu" then
        self:incrementElement()
    elseif button == "wd" then
        self:incrementElement(-1)
    end
end

function Gestures:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
    if not self:inButtonSpace(x) then 
        if button == "l" and self.drawPreviewLine then
            local endPoint = self:getNearestGridPoint(x, y)
            if self.rune == "fire" or self.rune == "ice" or self.rune == "earth" or self.rune == "air" then
                local line = Seg(self.startPoint, endPoint, element:getColor())
                if line:lengthSquared() > 0 then
                    table.insert(self.lines, line)
                end
            end
            print(self.startPoint, endPoint)
            self.lines = runeSystem:handleClick(self.rune, self.spellBook, self.lines, 
            self.startPoint, endPoint, self.firstGestureId)
        end
    end
    self.drawPreviewLine = false
end

function Gestures:inButtonSpace(x)
    return x < self.grid[1][1].x - conf.screenHeight*0.05
end

local function createImageButton(image, x, y, func, state)
    local button = loveframes.Create("imagebutton")
    button:SetState(state)
    button:SetPos(x, y)
    button:SetText("")
    button.OnClick = func
    button:SetImage(img.load(image))
    button:SizeToImage()
end

function Gestures:initGUI()
    -- Inits the buttons that determine what type of effect is currently being added
    local runeButtonTemplates =
    {
        fire = 
        {
            {imageName = "fireRune.png", func = function(object) self.rune = "fire" end}
        },
        ice = 
        {
            {imageName = "iceRune.png", func = function(object) self.rune = "ice" end}
        },
        air = 
        {
            {imageName = "airRune.png", func = function(object) self.rune = "air" end},
            {imageName = "airRune.png", func = function(object) self.rune = "force" end},
        },
        earth = 
        {
            {imageName = "earthRune.png", func = function(object) self.rune = "earth" end}
        },
    }
    local step = conf.screenHeight / 12
    for ele, buttons in pairs(runeButtonTemplates) do
        for i = 1, #buttons do
            local b = buttons[i]
            local x = math.floor((i - 1)/10)*step + step
            local y = ((i - 1) % 10)*step + 2*step
            createImageButton(b.imageName, x, y, b.func, ele)
        end
    end
    loveframes.SetState(element:getName())
end

function Gestures:initGrid()
    -- Gesture grid settings
    self.gridSize = 16
    self.gridXOffset = conf.screenWidth / 4
    self.gridYOffset = conf.screenHeight / 8
    local gapX = (conf.screenWidth - 2*self.gridXOffset) / self.gridSize
    local gapY = (conf.screenHeight - 2*self.gridYOffset) / self.gridSize
    self.grid = {}
    for i = 1, self.gridSize do
        self.grid[i] = {}
        for j = 1, self.gridSize do
            self.grid[i][j] = {x = gapX*i + self.gridXOffset, 
            y = gapY*j + self.gridYOffset}
        end
    end
end

function Gestures:getNearestGridPoint(x, y)
    -- Find the nearest grid point to the given point.
    local dist, minPoint
    local min = conf.screenWidth
    for i = 1, self.gridSize do
        for j = 1, self.gridSize do
            dist = distance(self.grid[i][j].x, self.grid[i][j].y, x, y)
            if dist < min then
                minPoint = Point(self.grid[i][j].x, self.grid[i][j].y)
                min = dist
            end
        end
    end
    return minPoint
end

function Gestures:deleteNearestLine(p)
    --TODO this funct is wrong. Unsure if table indexing or dist algo problem.
    local min = conf.screenWidth*conf.screenWidth
    local minIndex = 1
    local dist = min
    -- Find the nearest line in the current gesture to the given point
    for i = 1, #self.lines do
        dist = self.lines[i]:distToPointSquared(p)
        if dist < min then
            minIndex = i
            min = dist
        end
    end
    table.remove(self.lines, minIndex)
end

return Gestures
