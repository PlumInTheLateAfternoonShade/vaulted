-- Generate and draw a generic menu.

require ('utils')
local Class = require('class')
local GenMenu = Class
{
    name = 'GenMenu',
    function(self, items)
        -- self initiliazation
        self.items = items
        self.numItems = table.getn(items)
        self.pos = 1
        -- self font initialization
        love.graphics.setFont(love.graphics.newFont("fonts/Latine.ttf", 24*scale))
        self.fontColor = {r=0,g=0,b=0}
        self.fontYSize = 500*scale/self.numItems
        -- play menu audio
        -- From http://upload.wikimedia.org/wikipedia/commons/8/8e/CELLO_LIVE_PERFORMANCES_JOHN_MICHEL-Schumann_Folk_Pieces_Op_102_1st_mvt_.ogg
        -- on http://en.wikipedia.org/wiki/Wikipedia:Sound/list
        -- by http://johnmichel.com/johnmichel.com/Discography.html.
        local music = love.audio.newSource("music/menuMusic1.ogg", "stream")
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
        self:drawText(tostring(self.items[i]), 
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

function GenMenu:getCurrentItem()
    return self.items[self.pos]
end

function GenMenu:setToLastItem()
    self.pos = #self.items
end

return GenMenu
