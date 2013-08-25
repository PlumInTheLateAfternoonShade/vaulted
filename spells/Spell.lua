local VisibleIcon = require 'spells.VisibleIcon'
local Seg = require 'geometry.Seg'
local Region = require 'spells.Region'
local Class = require('class')

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
        self.lines[i] = Seg(nil, nil, nil, table.lines[i])
        self.iconLines[i] = Seg(nil, nil, nil, table.iconLines[i])
    end
    self.iconName = table.iconName
    self.power = table.power
    for i = 1, #table.regions do
        self.regions[i] = Region(nil, table.regions[i])
    end
end

function Spell:cast(world, caster)
    local x, y = caster.body:getWorldCenter()
    for i = 1, #self.regions do
        self.regions[i].effect:apply(world, caster)
    end
    -- Casting spells drains the caster's lifeforce.
    -- TODO: refuse to cast if it would kill the caster.
    --caster.damage = caster.damage + self.power
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
    for i = 1, #self.lines do
        l = self.lines[i]
        print('Line = '..tostring(l))
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
                        and l2.c.t == l3.c.t
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

function Spell:orderRegions()
    -- Force effect regions should occur last in the region list.
    local forceRegions = {}
    for i = #self.regions, 1, -1 do
        if self.regions[i].effect.name == 'Force' then
            table.insert(forceRegions, self.regions[i])
            table.remove(self.regions[i], i)
        end
    end
    for j = 1, #forceRegions do
        table.insert(self.regions, forceRegions[j])
    end
end

function Spell.__tostring(s)
    return '\n\nSPELL key: '..s.key..' power: '..s.power..'\n'
end

return Spell
