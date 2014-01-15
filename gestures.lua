-- Provides the UI for making new spell gestures.
require('utils')
local img = require 'images.img'
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local spellBookSystem = require 'systems.spellBookSystem'
local positionSystem = require 'systems.positionSystem'
local entitySystem = require 'systems.entitySystem'
local objectFactory = require 'systems.objectFactory'
local element = require 'components.element'
local Gestures = require 'class'
{
    name = 'Gestures',
    function(self)
        self.firstGestureId = entitySystem.currId + 1
        self.spellBook = spellBookSystem:get(heroId)
        spellBookSystem:preview(heroId)
        -- The lines in the currently loaded drawable gesture
        self.lines = {}
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
        love.graphics.line(startPoint.x, startPoint.y, mouseX, mouseY)
    end
end

local function getOtherPointFromLines(lines, point)
    for i = 1, #lines do
        local otherPoint = table.deepcopy(lines[i]:getOtherPoint(point))
        if otherPoint then
            table.remove(lines, i)
            return otherPoint
        end
    end
    return false
end

local function connectLinesIntoPolygon(lines)
    if #lines < 3 then return nil end
    local segs = table.deepcopy(lines)
    local points = {segs[1].p0, segs[1].p1}
    local lastPoint = points[2]
    table.remove(segs, 1)
    -- TODO look at the logic of this loop
    while #segs > 0 do
        lastPoint = getOtherPointFromLines(segs, lastPoint)
        if lastPoint then
            table.insert(points, lastPoint)
        else
            return nil
        end
    end
    if equals(lastPoint, points[1]) then
        table.remove(points, #points)
        return points
    end
    return nil
end

function Gestures:update(dt)
    loveframes.update(dt)
end

function Gestures:drawGrid()
    local smallDotRad = 5
    local bigDotRad = 8
    setColor({r=255, g=255, b=255})
    for i = 1, gridSize do
        for j = 1, gridSize do
            local dotRad
            if self:isPlayerDot(i, j) then
                dotRad = bigDotRad
            else
                dotRad = smallDotRad
            end
            love.graphics.circle("fill", grid[i][j].x, 
            grid[i][j].y, dotRad, 100)
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

local function incrementElement(amount)
    element:inc(amount)
    loveframes.SetState(element:getName())
end

function Gestures:keypressed(key)
    if key == up then
        incrementElement(-1)
    elseif key == down then
        incrementElement()
    elseif key == leftArrow then
        self:incrementSpell(-1)
    elseif key == rightArrow then
        self:incrementSpell()
    elseif key == confirm or key == gesture then
        -- Remove all gesture graphics components from screen
        entitySystem:deleteAllInRange(self.firstGestureId, entitySystem.currId)
        -- Go back to game.
        updateState("continue")
    end
end

function Gestures:mousepressed(x, y, button)
    if not main.state == 'gesture' then return end
    loveframes.mousepressed(x, y, button)
    if button == "l" then
        --left mouse starts drawing a line
        startPoint = self:getNearestGridPoint(x, y)
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
        incrementElement()
    elseif button == "wd" then
        incrementElement(-1)
    end
end

function Gestures:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
    if button == "l" then
        local endPoint = self:getNearestGridPoint(x, y)
        local line = Seg(startPoint, endPoint, element:getColor())
        if line:lengthSquared() > 0 then
            table.insert(self.lines, line)
        end
        self.drawPreviewLine = false
        local points = connectLinesIntoPolygon(self.lines)
        if points then
            self.spellBook[self.spellBook.i]:addComponentTable(
                objectFactory.prototypeElemental(points, Point(200, 200), element:get().name))
            self.lines = {}
        end
    end
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

local runeButtonTemplates =
{
    fire = 
    {
        {imageName ="fireRune.png", func = function(object) print("fire") end}
    },
    ice = 
    {
        {imageName ="iceRune.png", func = function(object) print("ice") end}
    },
    air = 
    {
        {imageName ="airRune.png", func = function(object) print("air") end},
        {imageName ="airRune.png", func = function(object) print("force") end},
    },
    earth = 
    {
        {imageName ="earthRune.png", func = function(object) print("earth") end}
    },
}

function Gestures:initGUI()
    -- Inits the buttons that determine what type of effect is currently being added
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
    gapX = (conf.screenWidth - 2*gridXOffset) / gridSize
    gapY = (conf.screenHeight - 2*gridYOffset) / gridSize
    grid = {}
    for i = 1, gridSize do
        grid[i] = {}
        for j = 1, gridSize do
            grid[i][j] = {x = gapX*i + gridXOffset, 
            y = gapY*j + gridYOffset}
        end
    end
end

function Gestures:getNearestGridPoint(x, y)
    -- Find the nearest grid point to the given point.
    local min = conf.screenWidth
    for i = 1, gridSize do
        for j = 1, gridSize do
            dist = distance(grid[i][j].x, grid[i][j].y, x, y)
            if dist < min then
                minPoint = Point(grid[i][j].x, grid[i][j].y)
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
