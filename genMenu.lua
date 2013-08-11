-- Generate and draw a generic menu.

require ('lib/class')

genMenu = {}

function genMenu:load(items)
    -- genMenu initiliazation
    genMenu.items = items
    genMenu.numItems = table.getn(items)
    genMenu.pos = 1
    -- genMenu font initialization
    font = love.graphics.newFont("fonts/Latine.ttf", 24*scale)
    love.graphics.setFont(font)
    genMenu.fontColor = {r=0,g=0,b=0}
    genMenu.fontYSize = 500*scale/genMenu.numItems
    -- play genMenu audio
    music = love.audio.newSource("music/music.ogg", "stream")
    music:setLooping(true)
    love.audio.play(music)
end

function genMenu:draw()
    -- draw genMenu text
    genMenu:drawItems()
end

function genMenu:update(dt)
  -- update highlighted genMenu
end

function genMenu:keypressed(key)
    if key == up then
        genMenu:incMenu(-1)
    elseif key == down then
        genMenu:incMenu(1)
    elseif key == confirm then
        love.audio.stop()
        updateState(genMenu.items[genMenu.pos])
    end
end

function genMenu:incMenu(inc)
    genMenu.pos = genMenu.pos + inc
    if genMenu.pos < 1 then
        genMenu.pos = genMenu.numItems
    elseif genMenu.pos > genMenu.numItems then
        genMenu.pos = 1
    end
end

function genMenu:drawItems()
    for i = 1, genMenu.numItems do
        genMenu:drawText(genMenu.items[i], 
                         genMenu.fontYSize + i*genMenu.fontYSize*scale, 
                         i == genMenu.pos)
    end
    setColorInverted(genMenu.fontColor)
end

function genMenu:drawText(text, pos, inverted)
    if inverted then
        -- Set unselected color
        setColorInverted(genMenu.fontColor)
        -- Draw a box around selected one
        love.graphics.rectangle("fill", 0, pos - (genMenu.fontYSize / 2)*scale, 
                                love.graphics.getWidth(), 
                                genMenu.fontYSize*scale)
        -- Set selected text color
        setColor(genMenu.fontColor)
    else
        -- Set unselected color
        setColorInverted(genMenu.fontColor)
    end
    -- Draw text
    love.graphics.printf(text,
        0, pos, love.graphics.getWidth(), "center")
end

function setColorInverted(color)
    love.graphics.setColor(255 - color.r, 255 - color.g,
                           255 - color.b)
end

function setColor(color)
    love.graphics.setColor(color.r, color.g, color.b)
end
