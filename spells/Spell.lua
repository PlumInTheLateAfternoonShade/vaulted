local VisibleIcon = require 'spells.VisibleIcon'
local Seg = require 'geometry.Seg'
local Region = require 'spells.Region'
local Class = require('class')

local manaMult = 6
local defaultSpellTable =
{
    lines = {},
    iconLines = {},
    iconName = "",
    power = 200,
    regions = {}
}

-- Defines a spell that can be cast by a caster.
local Spell = Class
{
    name = 'Spell',
    function(self, key, table)
        self.key = key
        self:selfConstruct(table or defaultSpellTable)
    end
}

function Spell:selfConstruct(table)
    self.lines = {}
    self.iconLines = {}
    self.regions = {}
    for i = 1, #table.lines do
        local l = table.lines[i]
        local iL = table.iconLines[i]
        self.lines[i] = Seg(
        Point(l.p0.x, l.p0.y), Point(l.p1.x, l.p1.y), l.c)
        self.iconLines[i] = Seg(
        Point(iL.p0.x, iL.p0.y), Point(iL.p1.x, iL.p1.y), iL.c)
    end
    self.iconName = table.iconName
    self.power = table.power
    for i = 1, #table.regions do
        self.regions[i] = Region(nil, table.regions[i])
    end
end

function Spell:cast(world, caster)
    -- Casting spells drains the caster's mana.
    if caster.mana < self.power*manaMult then
        return nil
    end
    caster.mana = caster.mana - self.power*manaMult
    local x, y = caster.body:getWorldCenter()
    local visuals = {}
    for i = 1, #self.regions do
        if self.regions[i].effect then
            local vis = self.regions[i].effect:apply(world, caster)
            if vis then
                table.insert(visuals, vis)
            end
        else
            print('Region '..i..' had no effect assigned.')
        end
    end
    local iconLines
    if caster.facingRight == 1 then
        iconLines = self.iconLines
    else
        iconLines = mirrorXListOfSegs(self.iconLines)
    end
    -- Note: tileSize is arbitrary for now. Should appear at caster's "hands".
    return VisibleIcon(iconLines, 
    x + tileSize*caster.facingRight, y - tileSize,
    os.clock()), visuals
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
    self:assignEffects()
    self:orderRegions()
    -- Debug output.
    print(tostring(self))
    for i = 1, #self.regions do
        print(tostring(self.regions[i]))
    end
end

function Spell:breakLinesIntoRegions()
    -- A region is an intersecting shape of same-element segs.
    self:resetRegioning()
    -- For each unregioned line, make a region.
    -- For each line in the region, check whether any other
    -- line in the spell qualifies to be part of its region.
    for i = 1, #self.lines do
        print('r: '..self.lines[i].c.r)
    end
    for i = 1, #self.lines do
        local l = self.lines[i]
        print('Line = '..tostring(l))
        if not l.regioned then
            local region = Region(l)
            table.insert(self.regions, region)
            l.regioned = #self.regions
            local j = 1
            while j <= #region.lines do
                local l2 = region.lines[j]
                for k = 1, #self.lines do
                    local l3 = self.lines[k]
                    if (not l3.regioned)
                        and (colorEquals(l2.c, l3.c))
                        and (l2:intersects(l3)) then
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
    self.iconLines = {}
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

function Spell:orderRegions()
    -- Force effect regions should occur last in the region list.
    local forceRegions = {}
    for i = #self.regions, 1, -1 do
        if self.regions[i].effect then
            if self.regions[i].effect.name == 'Force' then
                table.insert(forceRegions, self.regions[i])
                table.remove(self.regions[i], i)
            end
        end
    end
    for j = 1, #forceRegions do
        if self.regions[i].effect then
            table.insert(self.regions, forceRegions[j])
        end
    end
end

function Spell.__tostring(s)
    return '\n\nSPELL key: '..s.key..' power: '..s.power..'\n'
end

return Spell
