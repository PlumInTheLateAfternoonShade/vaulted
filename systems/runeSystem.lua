local Point = require 'geometry.Point'
local element = require 'components.element'
local Input = require 'components.Input'
local Walker = require 'components.Walker'

-- Handles rune components.
local runeSystem = {}

require('systems.componentSystem'):inherit(runeSystem)

function runeSystem:init(objectFactory)
    self.objectFactory = objectFactory
    self.components = {}

    local addTo = function(spellBook, componentTable)
        spellBook[spellBook.i]:addComponentTable(componentTable)
    end
    local addToExisting = function(spellBook, component, previewId)
        spellBook[spellBook.i]:addComponentToEntity(component, previewId)
    end
    local elementCreate = function(spellBook, lines, startPoint, endPoint, firstGestureId)
        local points = Point.connectLinesIntoPolygon(lines)
        if points then
            local center = computeCentroid(points)
            addTo(spellBook,
                objectFactory.prototypeElemental(points, center, element:get().name))
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
            addTo(spellBook, objectFactory.prototypeForce(h, v, startPoint.x, startPoint.y, heroId))
            return lines
        end,
        input = function(spellBook, previewId)
            addToExisting(spellBook, Input:new(false, false), previewId)
        end,
        walker = function(spellBook, previewId)
            addToExisting(spellBook, Walker:new(250, 500), previewId)
        end,
    }
end

function runeSystem:handleClick(rune, ...)
    return self.runePrototypers[rune](...)
end

return runeSystem
