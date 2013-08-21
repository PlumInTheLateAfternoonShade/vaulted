require('spells.Effect')
require('spells.Element')
require('spells.Force')
require('geometry.Point')
require('geometry.Seg')

effectFactory = {}
local forceConst = 5000000

function effectFactory:makeEffect(lines, element, power)
    print('Making effect. #lines = '..#lines)
    if #lines == 3 then
        -- Placeholder
        return self:makeForce(lines, element, power)
    end
end

function effectFactory:makeForce(lines, element, power)
    local dir = self:averageAngle(lines)
    local horzForce = power*math.cos(dir)*forceConst
    local vertForce = power*math.sin(dir)*forceConst
    local x = 0 -- Placeholder
    local y = 0 -- Placeholder
    print('Making a force effect with hF = '..horzForce..' vF = '..vertForce
    ..' angle = '..dir)
    return Force(horzForce, vertForce, x, y)
end

function effectFactory:averageAngle(lines)
    totalAngle = 0
    for i = 1, #lines do
        totalAngle = totalAngle + lines[i]:getAngle()
    end
    return totalAngle/#lines
end
