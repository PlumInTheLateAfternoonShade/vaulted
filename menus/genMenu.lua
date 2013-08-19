-- Generate and draw a generic menu.

require ('utils')
local Class = require('HardonCollider.class')
GenMenu = Class
{
    name = 'GenMenu',
    function(self, items)
        -- self initiliazation
        self.items = items
        self.numItems = table.getn(items)
        self.pos = 1
        -- self font initialization
        font = love.graphics.newFont("fonts/Latine.ttf", 24*scale)
        love.graphics.setFont(font)
        self.fontColor = {r=0,g=0,b=0}
        self.fontYSize = 500*scale/self.numItems
        -- play self audio
        music = love.audio.newSource("music/music.ogg", "stream")
        music:setLooping(true)
        love.audio.play(music)
    end
}

function GenMenu:draw()
    -- draw self text
    self:drawItems()
end

function GenMenu:update(dt)
    -- update highlighted self
end

function GenMenu:keypressed(key)
    if key == up then
        self:incMenu(-1)
    elseif key == down then
        self:incMenu(1)
    elseif key == confirm then
        love.audio.stop()
        updateState(self.items[self.pos])
    end
end

function GenMenu:incMenu(inc)
    self.pos = self.pos + inc
    if self.pos < 1 then
        self.pos = self.numItems
    elseif self.pos > self.numItems then
        self.pos = 1
    end
end

function GenMenu:drawItems()
    for i = 1, self.numItems do
        self:drawText(self.items[i], 
        self.fontYSize + i*self.fontYSize*scale, 
        i == self.pos)
    end
    setColorInverted(self.fontColor)
end

function GenMenu:drawText(text, pos, inverted)
    if inverted then
        -- Set unselected color
        setColorInverted(self.fontColor)
        -- Draw a box around selected one
        love.graphics.rectangle("fill", 0, pos - (self.fontYSize / 2)*scale, 
        love.graphics.getWidth(), 
        self.fontYSize*scale)
        -- Set selected text color
        setColor(self.fontColor)
    else
        -- Set unselected color
        setColorInverted(self.fontColor)
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
