local utils = {}
-- General utility functions

-- Deepcopy implementation from http://lua-users.org/wiki/CopyTable.
-- It seems to have been replaced now.
function objectDeepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, _copy(getmetatable(object)))
    end
    return _copy(object)
end

function setColorInverted(color)
    love.graphics.setColor(255 - color.r, 255 - color.g,
    255 - color.b, color.a)
end

function setColor(color)
    love.graphics.setColor(color.r, color.g, color.b, color.a)
end

function getColor()
    red, green, blue = love.graphics.getColor()
    return {r = red, g = green, b = blue}
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1))
end

function distanceSquared(x1, y1, x2, y2)
    return (x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1)
end

function within(x, x1, x2)
    big = math.max(x1, x2)
    little = math.min(x1, x2)
    return x >= little and x <= big
end

function limit(x, little, big)
    -- Limit x to within little and big.
    return math.min(big, math.max(little, x))
end

function wrappedInc(obj, amount)
    obj.i = obj.i + amount
    if obj.i < 1 then
        obj.i = #obj
    elseif obj.i > #obj then
        obj.i = 1
    end
end

-- By Bradley Smith, from
-- http://www.dzone.com/snippets/lua-unpack-multiple-tables
-- Returns all elements from all table arguments
function unpacks( ... )
    local values = {}
    -- Collect values from all tables
    for i = 1, select( '#', ... ) do
        for _, value in ipairs( select( i, ... ) ) do
            values[ #values + 1] = value
        end
    end
    return unpack( values )
end

function tableSwap(table, index1, index2)
    --Swap the values of index1 and index2 in the table.
    local value1 = table[index1]
    table[index1] = table[index2]
    table[index2] = value1
    return table
end

function printTable(preMessage, table, postMessage)
    postMessage = postMessage or "==================================="
    if preMessage then
        print(preMessage)
    end
    -- Print each member of the table
    for k, v in pairs(table) do
        print(tostring(k)..' = '..tostring(v))
    end
    print(postMessage)
end

function tableMax(table, field)
    -- Finds the entry with the max value of the specified field of the table.
    return tableCompare(table, field, greater)
end

function tableMin(table, field)
    -- Finds the entry with the min value of the specified field of the table.
    return tableCompare(table, field, less)
end

function tableCompare(table, field, compare)
    -- Finds the entry with the value of the specified field of the table
    -- determined to maximize the compare function
    if (not table) or #table == 0 then
        return nil
    end
    local max = table[1][field]
    local maxI = 1
    local maxEntry = table[1]
    for i = 1, #table do
        if not table[i] then
            print 'NOT table[i]!!' --TODO trying to diagnose rare bug. Delete when found.
            each(print, table)
        end
        if compare(table[i][field], max) then
            max = table[i][field]
            maxI = i
            maxEntry = table[i]
        end
    end
    return max, maxI, maxEntry
end

function utils.tableCompareNoField(table, compare)
    -- Finds the entry with the value of the entry of the table
    -- determined to maximize the compare function
    if (not table) or #table == 0 then
        return nil
    end
    local max = table[1]
    local maxI = 1
    for i = 1, #table do
        if compare(table[i], max) then
            max = table[i]
            maxI = i
        end
    end
    return max, maxI
end

function greater(a, b)
    return a > b
end

function less(a, b)
    return a < b
end

function colorEquals(color1, color2)
    return color1.r == color2.r and
    color1.g == color2.g and
    color1.b == color2.b
end

return utils
