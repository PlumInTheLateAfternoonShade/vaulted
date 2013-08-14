require 'VisibleIcon'
-- For casting spells.
local Class = require('HardonCollider.class')
Spell = Class
{
    name = 'Spell',
    function(self, key)
        self.key = key
        self.lines = {}
        self.iconName = "images/spells/"..key..".gif"
        self.power = 200 --Arbitrary for now. Calc based on length of lines
    end
}

function Spell:cast(num, caster)
    local x, y = caster:center()
    --TODO
    if num == 1 then
        caster.YVeloc = -400
    end
    -- Casting spells drains the caster's lifeforce.
    caster.damage = caster.damage + self.power
    -- Note: tileSize*3 is arbitrary for now.
    return VisibleIcon(self.icon, x + tileSize*3, y - tileSize*3, os.clock())
end

function Spell:finalize()
    self:saveIcon()
end

function Spell:saveIcon()
    local iconData = love.image.newImageData(iconSize, iconSize)
    -- placeholder icon
    for i = 0, 31 do
        iconData:setPixel(i, i, self.lines[1].c.r, self.lines[1].c.g, 
                            self.lines[1].c.b, 255)
    end
    -- make image
    self.icon = love.graphics.newImage(iconData)
    -- set filter to nearest
    self.icon:setFilter("nearest", "nearest")
end
