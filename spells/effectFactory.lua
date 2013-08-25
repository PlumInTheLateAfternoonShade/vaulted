require 'lib.deepcopy.deepcopy'
local Effect = require('spells.Effect')
require('spells.Element')
local Force = require('spells.Force')
local Conjure = require('spells.Conjure')
local Point = require('geometry.Point')
local Seg = require('geometry.Seg')

effectFactory = {}

local make = {}

local forceConst = 500

local choose = {
    function(lines, element, power)
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
    end,
    function(lines, element, power)
        print('Trying conjure. #lines = '..#lines..' element = '..element.t)
        -- TODO check is polygon and is convex
        -- love.physics polygons can have at most 8 sides
        if #lines > 8 then
            return nil
        end
        points = connectLinesIntoPolygon(lines)
        return make.conjure(points, element)
    end
}

function make.force(lines, element, power, longestLine)
    local angle = longestLine:getAngle()
    local horzForce = forceConst*power*math.cos(angle)
    local vertForce = -1.0*forceConst*power*math.sin(angle)
    local x, y = translatePointToWorldCoords(longestLine.p0)
    print('Making a force effect with hF = '..horzForce..' vF = '..vertForce
    ..' angle = '..angle)
    return Force(horzForce, vertForce, x, y)
end


function make.conjure(points, element)
    if points == nil then
        return nil
    end
    print('Making a conjure effect with element = '..element.t)
    -- TODO this is a hack.
    points = translatePolygonToWorldCoords(points)
    local cX = (points[1].x + points[2].x + points[3].x + points[4].x) / 4
    local cY = (points[1].y + points[2].y + points[3].y + points[4].y) / 4
    local center = Point(cX, cY)
    print('Conjure center = '..tostring(center))
    return Conjure(points, center, element)
end

function connectLinesIntoPolygon(lines)
    local segs = table.deepcopy(lines)
    local points = {segs[1].p0, segs[1].p1}
    local lastPoint = points[2]
    table.remove(segs, 1)
    while #segs > 0 do
        print('Start loop. #lines='..#lines..' #segs='..#segs..' #points='..#points)
        lastPoint = getOtherPointFromLines(segs, lastPoint)
        print('Mid loop. #lines='..#lines..' #segs='..#segs..' #points='..#points)
        if lastPoint then
            table.insert(points, lastPoint)
        else
            print('retnil 1')
            return nil
        end
        print('End loop. #lines='..#lines..' #segs='..#segs..' #points='..#points)
    end
    if equals(lastPoint, points[1]) then
        return points
    end
    print('retnil 2')
    return nil
end

function getOtherPointFromLines(lines, point)
    for i = 1, #lines do
        local otherPoint = table.deepcopy(lines[i]:getOtherPoint(point))
        if otherPoint then
            table.remove(lines, i)
            return otherPoint
        end
    end
    return false
end

function translatePolygonToWorldCoords(points)
    local coords = {}
    for i = 1, #points do
        local x, y = translatePointToWorldCoords(points[i])
        local coord = Point(x, y)
        table.insert(coords, coord)
    end
    return coords
end

function translatePointToWorldCoords(point)
    local x = (point.x - 8.5) * tileSize
    local y = (point.y - 9.5) * tileSize
    return x, y
end

function effectFactory:makeEffect(lines, element, power)
    print('Making effect.')
    --for i, v in pairs(choose) do
    for i = 1, #choose do
        local eff = choose[i](lines, element, power)
        if eff ~= nil then
            return eff
        end
    end
    return nil
end