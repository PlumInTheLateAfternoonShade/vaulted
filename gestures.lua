-- Provides the UI for making new spell gestures.
require('utils')
--local Class = require "HardonCollider/class"
require 'geometry.Point'
require 'geometry.Seg'
require 'spells.Spell'
require 'spellBook'
local Class = require 'HardonCollider.class'
require 'state'

Gestures = Class
{
    name = 'Gestures',
    function(self)
        setColor(eles[eles.i].c)
        -- The lines in the currently loaded gesture
        lines = spellBook[spellBook.i].lines
        -- Set up the drawing grid
        self:initGrid()
        drawPreviewLine = false
        love.graphics.setLineWidth(5)
    end
}
Gestures:inherit(State)

function Gestures:draw()
    -- Draw the grid of possible gesture points
    self:drawGrid()
    -- Draw each line in the current gesture
    self:drawLines()
    -- Draw the cursor
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    love.graphics.circle("fill", mouseX, mouseY, 10, 100)
    -- Draw the preview line if necessary
    if drawPreviewLine then
        love.graphics.line(startPoint.x, startPoint.y, mouseX, mouseY)
    end
end

function Gestures:drawGrid()
    local red, green, blue = love.graphics.getColor()
    setColor({r=255, g=255, b=255})
    for i = 1, gridSize do
        for j = 1, gridSize do
            love.graphics.circle("fill", grid[i][j].x, 
            grid[i][j].y, 5, 100)
        end
    end
    setColor({r=red, g=green, b=blue})
end

function Gestures:drawLines()
    local red, green, blue = love.graphics.getColor()
    --TODO convert to sensible for loop
    for i = 1, #lines do
        line = lines[i]
        setColor(line.c)
        love.graphics.line(line.p0.x, line.p0.y, line.p1.x, line.p1.y)
    end
    setColor({r=red, g=green, b=blue})
end

function Gestures:keypressed(key)
    if key == left then
        eles.inc(-1)
    elseif key == right then
        eles.inc(1)
    elseif key == up then
        spellBook.inc(-1)
        lines = spellBook[spellBook.i].lines
    elseif key == down then
        spellBook.inc(1)
        lines = spellBook[spellBook.i].lines
    elseif spellBook.keyMatch(key) then
        lines = spellBook[spellBook.i].lines
    elseif key == confirm or key == gesture then
        -- Finalize and save spells
        spellBook.finalize()
        -- Go back to game.
        setColorInverted(fontColor)
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
        eles.inc(1)
    elseif button == "wd" then
        eles.inc(-1)
    end
end

function Gestures:mousereleased(x, y, button)
    if button == "l" then
        local endPoint = self:getNearestGridPoint(x, y)
        local line = Seg(startPoint, endPoint, eles[eles.i].c)
        if line:lengthSquared() > 0 then
            table.insert(lines, line)
        end
        drawPreviewLine = false
    end
end

function Gestures:initGrid()
    gapX = (screenWidth - 2*gridXOffset) / gridSize
    gapY = (screenHeight - 2*gridYOffset) / gridSize
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
    local min = screenWidth
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
    local min = screenWidth*screenWidth
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
