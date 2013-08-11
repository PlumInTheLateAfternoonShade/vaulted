menu = {}

function menu.load()
    -- menu initiliazation
    menu.items = {"continue", "settings", "exit"}
    menu.numItems = table.getn(menu.items)
    menu.pos = 1
    -- menu font initialization
    font = love.graphics.newFont("fonts/menuFont.ttf",14*scale)
    love.graphics.setFont(font)
    menu.fontColor = {r=0,g=0,b=0}
    menu.fontYSize = 150
    -- play menu audio
    music = love.audio.newSource("music/music.ogg", "stream")
    music:setLooping(true)
    love.audio.play(music)
end

function menu.draw()
    -- draw menu title
    love.graphics.draw(imgs["menuTitle"], 0, 0, 0, scale, scale)
    -- draw menu text
    menu.drawItems()
end

function menu.update(dt)
  -- update highlighted menu
end

function menu.keypressed(key)
    if key == "up" then
        menu.incMenu(-1)
    elseif key == "down" then
        menu.incMenu(1)
    elseif key == "return" then
        choice = menu.items[menu.pos]
        if choice == "continue" then
            main.state = "game"
        elseif choice == "settings" then
            main.state = "settings"
        elseif choice == "exit" then
            main.state = "saveAndExit"
        end
    end
end

function menu.keyreleased(key)
end

function menu.incMenu(inc)
    menu.pos = menu.pos + inc
    if menu.pos < 1 then
        menu.pos = menu.numItems
    elseif menu.pos > menu.numItems then
        menu.pos = 1
    end
end

function menu.drawItems()
    for i = 1, menu.numItems do
        menu.drawText(menu.items[i], 
                      menu.fontYSize + i*menu.fontYSize*scale, i == menu.pos)
    end
    menu.setColorInverted(menu.fontColor)
end

function menu.drawText(text, pos, inverted)
    if inverted then
        -- Set unselected color
        menu.setColorInverted(menu.fontColor)
        -- Draw a box around selected one
        love.graphics.rectangle("fill", 0, pos - (menu.fontYSize / 2)*scale, 
                                love.graphics.getWidth(), 
                                menu.fontYSize*scale)
        -- Set selected text color
        menu.setColor(menu.fontColor)
    else
        -- Set unselected color
        menu.setColorInverted(menu.fontColor)
    end
    -- Draw text
    love.graphics.printf(text,
        0, pos, love.graphics.getWidth(), "center")
end

function menu.setColorInverted(color)
    love.graphics.setColor(255 - color.r, 255 - color.g,
                           255 - color.b)
end

function menu.setColor(color)
    love.graphics.setColor(color.r, color.g, color.b)
end
