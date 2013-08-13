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
    --TODO cycle thru avail gestures (spells)
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
        --left mouse starts drawing a line
        startX, startY = gestures.getNearestGridPoint(x, y)
        drawPreviewLine = true
    elseif button == "r" then
        --right mouse deletes the closest line
        if numLines > 0 then
            lineToDelete = gestures.getNearestLine(x, y)
            --table.remove(lines, lineToDelete)
            --numLines = numLines - 1
        end
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

function gestures.getNearestLine(x, y)
    --TODO this funct is wrong. Unsure if table indexing or dist algo problem.
    min = screenWidth*screenWidth
    minIndex = 1
    -- Find the nearest line in the current gesture to the given point
    for i = 1, numLines do
        l = lines[i]
        dist = distToSegmentSquared(x, y, l.x1, l.y1, l.x2, l.y2)
        --[[dx = l.x2 - l.x1
        dy = l.y2 - l.y1
        -- TODO simplify this mess, div by zero potential!
        -- Get intersection point with the line
        x3 = (dx*dx*x - dx*dy*y + dy*dy*l.x1 - dx*dy*l.y1)/(dy*dy + dx*dx)
        y3 = (dy/dx)*(x3 - l.x1) + l.y1
        -- If within x coordinates of line, compute distance to line
        -- Otherwise compute distance to closest endpoint
        if within(x3, l.x1, l.x2) then
            dist = distanceSquared(x, y, x3, y3)
        else
            dist = math.min(distanceSquared(x, y, l.x1, l.y1), distanceSquared(x, y, l.x2, l.y2))
        end]]--
        print("i: "..i.." dist: "..dist.." min: "..min)
        if dist < min then
            minIndex = i
            min = dist
        end
    end

    table.remove(lines, minIndex)
    numLines = table.getn(lines) --numLines - 1
    return minIndex
end

function distToSegmentSquared(px, py, vx, vy, wx, wy)
    l2 = distance(vx, vy, wx, wy)
    if (l2 == 0) then return distance(px, py, vx, vy) end
    t = ((px - vx) * (wx - vx) + (py - vy) * (wy - vy)) / l2
    if (t < 0) then return distance(px, py, vx, vy) end
    if (t > 1) then return distance(px, py, wx, wy) end
    return distance(px, py, vx + t * (wx - vx), vy + t * (wy - vy))
end
