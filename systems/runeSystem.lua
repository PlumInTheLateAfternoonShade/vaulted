local Point = require 'geometry.Point'
local element = require 'components.element'

-- Handles rune components.
local runeSystem = {}

require('systems.componentSystem'):inherit(runeSystem)

function runeSystem:init(objectFactory)
    self.objectFactory = objectFactory
    self.components = {}

    local addTo = function(spellBook, componentTable)
        spellBook[spellBook.i]:addComponentTable(componentTable)
    end
    local elementCreate = function(spellBook, lines, startPoint, endPoint, firstGestureId)
        local points = Point.connectLinesIntoPolygon(lines)
        if points then
            addTo(spellBook,
                -- TODO set at centroid of points, not endpoint
                objectFactory.prototypeElemental(points, endPoint, element:get().name))
            lines = {}
        end
        return lines
    end
    self.runePrototypers =
    {
        fire = elementCreate,
        ice = elementCreate,
        earth = elementCreate,
        air = elementCreate,
        force = function(spellBook, lines, startPoint, endPoint, firstGestureId)
            local h = endPoint.x - startPoint.x
            local v = endPoint.y - startPoint.y
            print("force", startPoint, endPoint, h, v)
            addTo(spellBook, objectFactory.prototypeForce(h, v, startPoint.x, startPoint.y, heroId))
            return lines
        end,
    }
end

function runeSystem:handleClick(rune, ...)
    return self.runePrototypers[rune](...)
end

return runeSystem
