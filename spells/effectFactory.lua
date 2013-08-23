require 'lib.deepcopy.deepcopy'
local Effect = require('spells.Effect')
require('spells.Element')
local Force = require('spells.Force')
local Point = require('geometry.Point')
local Seg = require('geometry.Seg')

effectFactory = {}

local make = {}

local forceConst = 500

local choose = {
    force = function(lines, element, power)
        print('Trying force. #lines = '..#lines..' element = '..element.t)
        if #lines == 3 and element.t == air.t then
            local longestLine, shorterLines = getLongestLine(lines)
            local frontP0 = longestLine:sharesAPoint(shorterLines[1])
            local frontP1 = longestLine:sharesAPoint(shorterLines[2])
            print('frontP0: '..tostring(frontP0)..' frontP1: '..tostring(frontP1))
            if not frontP0 or not frontP1 then
                return nil
            elseif not equals(frontP0, frontP1) then
                return nil
            end
            local otherP = longestLine:getOtherPoint(frontP0)
            print('otherP: '..tostring(otherP))
            local chosenLine = Seg(frontP0, otherP, longestLine.c)
            return make.force(lines, element, power, chosenLine)
        end
        return nil
    end
}

function make.force(lines, element, power, longestLine)
    local angle = longestLine:getAngle()
    local horzForce = forceConst*power*math.cos(angle)
    local vertForce = -1.0*forceConst*power*math.sin(angle)
    local x = 0 -- Placeholder
    local y = 0 -- Placeholder
    print('Making a force effect with hF = '..horzForce..' vF = '..vertForce
    ..' angle = '..angle)
    return Force(horzForce, vertForce, x, y)
end

function effectFactory:makeEffect(lines, element, power)
    print('Making effect.')
    for i, v in pairs(choose) do
        local eff = v(lines, element, power)
        if eff ~= nil then
            return eff
        end
    end
    return nil
end
