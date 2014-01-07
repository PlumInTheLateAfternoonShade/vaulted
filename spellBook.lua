-- A table of all the hero's spells.

local Spell = require 'spells.Spell'
local VisibleIcon = require 'spells.VisibleIcon'
require 'utils'
local Class = require 'class'
local defaultSpellBookTable =
{
    i = 1,
    Spell(spell1),
    Spell(spell2),
    Spell(spell3),
    Spell(spell4)
}

local SpellBook = Class
{
    name = 'SpellBook',
    function(self, table)
        self:selfConstruct(table or defaultSpellBookTable)
    end
}

function SpellBook:selfConstruct(table)
    self.i = table.i
    for j = 1, #table do
        self[j] = Spell(spellKey[j], table[j])
    end
end

function SpellBook:inc(amount)
    wrappedInc(self, amount)
end

function SpellBook:keyMatch(key)
    -- Return true and set i to the appropriate spell if
    -- the key matches any of the spell's keys.
    if key == leftArrow then
        self:inc(-1)
        return false
    elseif key == rightArrow then
        self:inc(1)
        return false
    elseif key == confirm then
        return true
    else
        for j = 1, #self do
            if self[j].key == key and table.getn(self[j].lines) ~= 0 then
                self.i = j
                return true
            end
        end
    end
    return nil
end

function SpellBook:draw(left, top, width, height)
    -- Draws the spellbook UI.
    local numVisible = math.floor(width/height)
    local adjWidth = numVisible*height
    local adjLeft = (width - adjWidth)/2
    for i = 1, numVisible do
        setColor({r=0, g=0, b=0})
        if i == self.i then
            setColor({r=100, g=50, b=50})
        end
        
        love.graphics.rectangle("fill", height*(i-1) + adjLeft, top, height, height)
        -- TODO: This should not be computed every iter, but only when
        -- the spells change.
        if self[i] then
            setColor({r=255, g=255, b=255})
            local key = self[i].key
            if key == " " then
                key = "space"
            end
            love.graphics.print(key, 
            height*(i - 1) + adjLeft, height*0.1 + top)
            local visIcon = VisibleIcon(self[i].iconLines, 
            height*(i - 1) + adjLeft, top, 0, height/16)
            visIcon:draw()
        end
    end
end

function SpellBook:finalize()
    --TODO: should only finalize changed spells?
    for j = 1, #self do
        if #self[j].lines ~= 0 then
            self[j]:finalize()
        end
    end
end



return SpellBook
