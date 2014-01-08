local Point = require 'geometry.Point'
local positionSystem = require 'systems.positionSystem'

-- System for rendering graphics
local graphicsSystem = {}

function graphicsSystem.add(comp)
    graphicsSystem[comp.id] = comp
end

function graphicsSystem.draw()
    for i = #graphicsSystem, 1, -1 do
        local comp = graphicsSystem[i]
        setColor(comp.color)
        love.graphics.polygon("fill", unpack(positionSystem[comp.id].coords))
    end
end

return graphicsSystem
