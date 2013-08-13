-- Provides the UI for making new spell gestures.
require('utils')
--local Class = require "HardonCollider/class"
require "element"


gestures = {}

-- A table of elements
fire = Element('fire', fireColor)
water = Element('water', waterColor)
earth = Element('earth', earthColor)
air = Element('air', airColor)
numElements = 4
eles = {fire, water, earth, air, i=1}

function gestures.load()
    setColor(eles[eles.i].c)
    -- The lines in the currently loaded gesture
    lines = {}
    -- Set up the drawing grid
    gestures.initGrid()
    drawPreviewLine = false
    numLines = 0
end

function eles.inc(amount)
    eles.i = eles.i + amount
    if eles.i < 1 then
        eles.i = numElements
    elseif eles.i > numElements then
        eles.i = 1
    end
    setColor(eles[eles.i].c)
end

function gestures.draw()
    -- Draw the grid of possible gesture points
    gestures.drawGrid()
    -- Draw each line in the current gesture
    gestures.drawLines()
    -- Draw the cursor
    mouseX = love.mouse.getX()
    mouseY = love.mouse.getY()
    love.graphics.circle("fill", mouseX, mouseY, 10, 100)
    -- Draw the preview line if necessary
    if drawPreviewLine then
        love.graphics.setLineWidth(5)
        love.graphics.line(startX, startY, mouseX, mouseY)
    end
end

function gestures.drawGrid()
    red, green, blue = love.graphics.getColor()
    setColor({r=255, g=255, b=255})
    for i = 1, gridSize do
        for j = 1, gridSize do
            love.graphics.circle("fill", grid[i][j].x, 
            grid[i][j].y, 5, 100)
        end
    end
    setColor({r=red, g=green, b=blue})
end

function gestures.drawLines()
    red, green, blue = love.graphics.getColor()
    --TODO convert to sensible for loop
    for i = 1, numLines do
        line = lines[i]
        setColor(line.c)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2)
    end
    setColor({r=red, g=green, b=blue})
end

function gestures.keypressed(key)
    if key == up then
        eles.inc(-1)
    elseif key == down then
        eles.inc(1)
    elseif key == openMenu then
        setColor(genMenu.fontColor)
        updateState("back to main menu")
    elseif key == confirm then
        setColorInverted(genMenu.fontColor)
        updateState("game")
    end
end

function love.mousepressed(x, y, button)
    if button == "l" then
        startX, startY = gestures.getNearestGridPoint(x, y)
        drawPreviewLine = true
    end
end

function love.mousereleased(x, y, button)
    if button == "l" then
    endX, endY = gestures.getNearestGridPoint(x, y)
    numLines = numLines + 1
    lines[numLines] = {x1 = startX, y1 = startY, x2 = endX, y2 = endY,
    c = eles[eles.i].c}
    drawPreviewLine = false
end
end

function gestures.initGrid()
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

function gestures.getNearestGridPoint(x, y)
    -- Find the nearest grid point to the given point.
    min = screenWidth
    minX = 0
    minY = 0
    for i = 1, gridSize do
        for j = 1, gridSize do
            dist = distance(grid[i][j].x, grid[i][j].y, x, y)
            if dist < min then
                minX = grid[i][j].x
                minY = grid[i][j].y
                min = dist
            end
        end
    end
    return minX, minY
end
