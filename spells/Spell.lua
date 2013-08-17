require 'spells.VisibleIcon'
require 'spells.Region'
-- For casting spells.
local Class = require('HardonCollider.class')
Spell = Class
{
    name = 'Spell',
    function(self, key)
        self.key = key
        self.lines = {}
        self.iconLines = {}
        self.iconName = "images/spells/"..key..".gif" --TODO delete, probably
        self.power = 200
        self.regions = {}
    end
}

function Spell:cast(num, caster)
    local x, y = caster:center()
    --TODO
    if num == 1 then
        caster.YVeloc = -400
    end
    -- Casting spells drains the caster's lifeforce. 
    -- TODO: refuse to cast if it would kill the caster.
    caster.damage = caster.damage + self.power
    -- Note: tileSize*3 is arbitrary for now.
    return VisibleIcon(self.iconLines, x + tileSize*3, y - tileSize*3, os.clock())
end

function Spell:finalize()
    --self:saveIcon()
    self:removeRedundantLines()
    self:analyzeLines()
end
--[[
function Spell:saveIcon()
    local iconData = love.image.newImageData(iconSize, iconSize)
    -- placeholder icon (TODO)
    for i = 0, iconSize-1 do
        iconData:setPixel(i, i, self.lines[1].c.r, self.lines[1].c.g, 
        self.lines[1].c.b, 255)
    end
    -- make image
    self.icon = love.graphics.newImage(iconData)
    -- set filter to nearest
    self.icon:setFilter("nearest", "nearest")
end]]--

function Spell:removeRedundantLines()
    -- placeholder (TODO)
end

function Spell:analyzeLines()
    self:breakLinesIntoRegions()
    self:compressRegions()
    self:assignPower()
    --self:assignEffects()
    -- Debug output.
    print(tostring(self))
    for i = 1, #self.regions do
        print(tostring(self.regions[i]))
    end

end

function Spell:breakLinesIntoRegions()
    -- A region is an intersecting shape of same-element segs,
    self:resetRegioning()
    for i = 1, #self.lines do
        l = self.lines[i]
        if not l.regioned then
            region = Region(l)
            table.insert(self.regions, region)
            l.regioned = #self.regions
            j = 1
            while j <= #region.lines do
                l2 = region.lines[j]
                for k = 1, #self.lines do
                    l3 = self.lines[k]
                    if not l3.regioned
                        and l2.c == l3.c
                        and l2:intersects(l3) then
                        l3.regioned = l2.regioned
                        table.insert(region.lines, l3)
                    end
                end
                j = j + 1
            end
        end
    end
end

function Spell:resetRegioning()
    for k,v in pairs(self.regions) do self.regions[k] = nil end
    for i = 1, #self.lines do
        self.lines[i].regioned = nil
    end
end

function Spell:compressRegions()
    -- The x, y are compressed into 1 to 16.
    for i = 1, #self.regions do
        self.regions[i]:compress()
        for j = 1, #self.regions[i].lines do
            table.insert(self.iconLines, self.regions[i].lines[j])
        end
    end
end

function Spell:assignPower()
    -- The regions each get assigned a power based on their total lengths.
    -- The spell's power is the total of this.
    self.power = 0
    for i = 1, #self.regions do
        self.power = self.power + self.regions[i]:assignPower()
    end
end

function Spell:assignEffects()
    -- Figures out what effect each region has on the world
    -- based on its shape.
    for i = 1, #self.regions do
       self.regions[i]:assignEffect()
    end
end

function Spell.__tostring(s)
    return '\n\nSPELL key: '..s.key..' power: '..s.power..'\n'
end
