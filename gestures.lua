-- Provides the UI for making new spell gestures.
require('utils')
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local spellBookSystem = require 'systems.spellBookSystem'
local graphicsSystem = require 'systems.graphicsSystem'
local State = require 'state'
local element = require 'components.element'
local lines
local spellBook
local Gestures = require 'class'
{
    name = 'Gestures',
    function(self)
        --spellBook = spellBookSystem:get(heroId)
        -- The lines in the currently loaded gesture
        --print(spellBook.i)
        lines = {} --spellBook[spellBook.i].lines
        -- Set up the drawing grid
        self:initGrid()
        drawPreviewLine = false
    end
}
Gestures:inherit(State)

function Gestures:draw()
    -- Draw the world of gestures
    graphicsSystem:draw()
    -- Draw the grid of possible gesture points
    self:drawGrid()
    -- Draw each line in the current gesture
    self:drawLines()
    -- Draw the cursor
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    element:setAsColor()
    love.graphics.circle("fill", mouseX, mouseY, 10, 100)
    -- Draw the preview line if necessary
    if drawPreviewLine then
        love.graphics.line(startPoint.x, startPoint.y, mouseX, mouseY)
    end
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
    for i = 1, #lines do
        local line = lines[i]
        setColor(line.c)
        love.graphics.line(line.p0.x, line.p0.y, line.p1.x, line.p1.y)
    end
end

function Gestures:keypressed(key)
    if key == up then
        element:inc(-1)
    elseif key == down then
        element:inc()
    --[[elseif spellBook:keyMatch(key) ~= nil then
        lines = spellBook[spellBook.i].lines]]--
    elseif key == confirm or key == gesture then
        -- Finalize and save spells
        --spellBook:finalize()
        -- Go back to game.
        print('Returning to game from gestures.')
        updateState("continue")
    end
end

function Gestures:mousepressed(x, y, button)
    if not main.state == 'gesture' then return end
    if button == "l" then
        --left mouse starts drawing a line
        startPoint = self:getNearestGridPoint(x, y)
        drawPreviewLine = true
    elseif button == "r" then
        --right mouse deletes the closest line
        if #lines > 0 then
            self:deleteNearestLine(Point(x, y))
        end
    elseif button == "wu" then
        element:inc()
    elseif button == "wd" then
        element:inc(-1)
    end
end

function Gestures:mousereleased(x, y, button)
    if button == "l" then
        local endPoint = self:getNearestGridPoint(x, y)
        local line = Seg(startPoint, endPoint, element:getColor())
        if line:lengthSquared() > 0 then
            table.insert(lines, line)
        end
        drawPreviewLine = false
    end
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
    for i = 1, #lines do
        dist = lines[i]:distToPointSquared(p)
        if dist < min then
            minIndex = i
            min = dist
        end
    end
    table.remove(lines, minIndex)
end

return Gestures
