local manaSystem = require 'systems.manaSystem'

-- Handles spellBook components.
local spellBookSystem = {}

require('systems.componentSystem'):inherit(spellBookSystem)

function spellBookSystem:cast(id, index)
    if manaSystem:deduct(id, self.components[id][index].power) then
        return self.components[id][index]:cast(id)
    end
end

function spellBookSystem:inc(id, amount)
    amount = amount or 1
    wrappedInc(self.components[id], amount)
end

function spellBookSystem:deleteFromCurrent(id, deleteId)
    local comp = self.components[id]
    comp[comp.i]:delete(deleteId)
end

function spellBookSystem:preview(id)
    local comp = self.components[id]
    comp[comp.i]:preview()
end

function spellBookSystem:draw(id)
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
            local key = "k" --TODO fix
            if key == " " then
                key = "space"
            end
            love.graphics.print(key, 
            height*(i - 1) + adjLeft, height*0.1 + top)
        end
    end
end

return spellBookSystem
