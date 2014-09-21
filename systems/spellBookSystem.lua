local keys =  require 'keys'
local manaSystem = require 'systems.manaSystem'
local SpellBook = require('components.SpellBook')
local ComponentSystem = require('systems.ComponentSystem')

-- Handles joint components.
local SpellBookSystem = require('lib.middleclass')(
    'SpellBookSystem', ComponentSystem)

function SpellBookSystem:init(referenceSystem, entities)
    self.components = entities[SpellBook]
    ComponentSystem.init(self, referenceSystem)
end

function SpellBookSystem:cast(id, index)
    local comp = self.components[id]
    if comp.coolDown:canFire() then
        if manaSystem:deduct(id, comp[index].power) then
            comp.coolDown:fire() 
            return comp[index]:cast(id)
        end
    end
end

function SpellBookSystem:inc(id, amount)
    amount = amount or 1
    wrappedInc(self.components[id], amount)
end

function SpellBookSystem:deleteFromCurrent(id, deleteId)
    local comp = self.components[id]
    comp[comp.i]:delete(deleteId)
end

function SpellBookSystem:preview(id)
    local comp = self.components[id]
    comp[comp.i]:preview()
end

function SpellBookSystem:draw(id)
    -- Draws the spellbook UI.
    local left, top, width, height = 0, 0, conf.screenWidth, conf.screenHeight * 0.1
    local comp = self.components[id]
    local numVisible = math.floor(width/height)
    local adjWidth = numVisible*height
    local adjLeft = (width - adjWidth)/2
    for i = 1, numVisible do
        setColor({r=0, g=0, b=0})
        if i == comp.i then
            setColor({r=100, g=50, b=50})
        end
        
        love.graphics.rectangle("fill", height*(i-1) + adjLeft, top, height, height)
        if comp[i] then
            setColor({r=255, g=255, b=255})
            love.graphics.print(keys.spells[i], 
            height*(i - 1) + adjLeft, height*0.1 + top)
        end
    end
    setColor({r=255, g=255, b=255})
    love.graphics.print(string.format('CD: %g', comp.coolDown:getPercent()),
        conf.screenWidth*0.9,
        conf.screenHeight*0.5)
    love.graphics.print(string.format('CD raw: %g', comp.coolDown.metro.time),
        conf.screenWidth*0.9,
        conf.screenHeight*0.4)
end

function SpellBookSystem:update(dt)
    for id, comp in pairs(self.components) do
        comp.coolDown:tick(dt)
    end
end

return SpellBookSystem:new()
