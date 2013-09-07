require 'utils'
local Class = require 'class'
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local CollidableObject = require 'collidableObject'
local FireParticleSystem = require 'particles.fireParticleSystem'
local deathSeconds = 0.3 --TODO: In tens of seconds for some reason?
-- Defines an object in the game world that is a specific element.
-- Just a rectangle for now.
local ElementalObject = Class
{
    name = 'ElementalObject',
    function(self, world, points, center, element)
        local name = element.t..'Object'
        self.element = element
        CollidableObject.construct(self, world, points, center, 
        element.friction, 'dynamic', element.c, name)
        self.eleObjFirstUpdate = true
        self.partUpdateCounter = 1000
        self.maxMassToBreak = 10 --element.density*1 --Pretty arbitrary (TODO)
        self.ambientTemp = element.temp
        self.temp = self.ambientTemp
    end
}
ElementalObject:inherit(CollidableObject)

function ElementalObject:draw()
    setColor(self.color)
    if self.particle then
        self.particle:draw(self.body:getX(), self.body:getY(), 
        self.body:getAngle())
    else
        love.graphics.polygon("fill",
        self.body:getWorldPoints(self.shape:getPoints()))
    end
end

function ElementalObject:update(dt)
    CollidableObject.update(self, dt)
    if self.eleObjFirstUpdate then
        self.fixture:setDensity(self.element.density)
        self.body:setGravityScale(self.element.gravScale)
        self.body:resetMassData()
        if self.element.t == 'fire' then
            self.particle = FireParticleSystem(self.fixture, self.color)
        end
        self.eleObjFirstUpdate = false
    end
    if self.particle then
        self.partUpdateCounter = self.partUpdateCounter + dt
        if self.partUpdateCounter >= dt*3 then
            local vX, vY = self.body:getLinearVelocity()
            if self.expireTime ~= 0 then
                self.particle:reduce(self.expireTime, deathSeconds)
            end
            self.particle:update(self.partUpdateCounter, vX, vY, self.color)
            self.partUpdateCounter = 0
        end
    end
end

function ElementalObject:beginCollision(other, contact, world)
    --TODO: Separate elements into 4 classes? Kind of annoying.
    --print('expireTime: '..self.expireTime)
    if (self.element.t == 'fire' or self.element.t == 'water')
    and self.expireTime == 0 then --TODO bug with fire!
        local deleteSeconds = nil
        if self.body:getMass() > self.maxMassToBreak then
            self:centralize(self:computeCentroid())
            local conSeg = self:getContactSeg(contact)
            local points1, points2 = breakNearSeg(self.points, conSeg)
            if points1 and points2 and #points1 > 2 and #points2 > 2 then
                -- Order the points so they form a valid convex polygon.
                points1 = convexHull(points1)
                points2 = convexHull(points2)
                
                -- Compute their new center points.
                local newCenter1 =
                computeCentroid(points1) + self.center
                local newCenter2 = 
                computeCentroid(points2) + self.center

                -- Debug prints
                print('area1: '..computeArea(points1))
                printTable('points1: ', points1)
                print('area2: '..computeArea(points2))
                printTable('points2: ', points2)

                -- Construct the elemental objects.
                local obj1 = self:makeChildObject(points1, newCenter1)
                local obj2 = self:makeChildObject(points2, newCenter2)

                -- Assign their velocities
                local vX, vY = self.body:getLinearVelocity()
                local v = Point(vX, vY)
                local newV1 = self:getNewVelocity(v, newCenter1)
                local newV2 = self:getNewVelocity(v, newCenter2)
                obj1:queueVelocity(newV1)
                obj2:queueVelocity(newV2)
                -- Insert them into the object table.
                table.insert(objects, obj1)
                table.insert(objects, obj2)
                self:setDeleteTime(-1)
            end
        elseif self.element.t == 'fire' then
            deleteSeconds = deathSeconds
        end
        if deleteSeconds then
            print('Deleting in '..deleteSeconds..'.')
            self:setDeleteTime(deleteSeconds)
        end
    end
    CollidableObject.beginCollision(self, other, contact, world)
end

function ElementalObject:getNewVelocity(v, newCenter)
    local speed = v:magnitude()
    local newV = Seg(self.center, newCenter):normalize()
    newV:scale(speed)
    return newV
end

function ElementalObject:makeChildObject(points, center)
    return ElementalObject(self.world, points, center, self.element)
end

function coordsToPoints(...)
    local num = select('#', ...)
    local points = {}
    for i = 1, num, 2 do
        local x = select(i, ...)
        local y = select(i + 1, ...)
        table.insert(points, Point(x, y))
    end
    return points
end

function ElementalObject:getContactSeg(contact)
    local cx, cy = contact:getPositions() --Gets the first pos only.
    -- Generate another point to make a line
    local c = Point(cx, cy)
    local p = c:getReflectAcrossPoint(self.center)
    c:offset(-self.center.x, -self.center.y)
    p:offset(-self.center.x, -self.center.y)
    return Seg(c, p)
end

function breakNearSeg(points, seg)
    -- Finds the two points closest to the seg's endpoints
    -- and returns two collections of points on either side.
    print('breaking near seg '..tostring(seg))
    printTable('points:\n====', points, '===')
    local ps = table.deepcopy(points)
    local p0, i = nearestPoint(ps, seg.p0)
    local p1, j = nearestPoint(ps, seg.p1)
    if #points == 3 then
        -- If it's a triangle, we can't break it along two points.
        -- So we break it along one point and the midpoint of the
        -- opposite seg.

        -- Get the opposite seg's points
        table.remove(ps, i)
        -- Compute midpoint of that seg.
        local mP = midPoint(ps[1], ps[2])
        print('p0: '..tostring(p0)..' opp1: '..tostring(ps[1])..' opp2: '..tostring(ps[2])..' mP: '..tostring(mP))
        -- Return two triangles formed by a cut through p0 and the midpoint.
        return {p0, ps[1], mP}, {p0, ps[2], mP}
    end
    if math.abs(i - j) <= 1 then
        print('Wouldn\'t get two polygons. i = '..i..' j = '..j..' # = '..#points)
        -- Don't break it if we wouldn't get two polygons out of it.
        return points
    end
    local side1 = {}
    local side2 = {}
    local nearSeg = Seg(p0, p1)
    for k = 1, #points do
        local found = nearSeg:findSidePointIsOn(points[k])
        print(k..' = Found: '..found..' points[k]: '..tostring(points[k]))
        --TODO: Hacky fix for floating point errors.
        if found > 0.001 then
            table.insert(side1, points[k])
        elseif found < -0.001 then
            table.insert(side2, points[k])
        end
    end
    table.insert(side2, p0)
    table.insert(side2, p1)
    table.insert(side1, p0)
    table.insert(side1, p1)
    removeRedundantPoints(side1)
    removeRedundantPoints(side2)
    -- debug
    printTable('Broken side1:\n====', side1, '===')
    printTable('Broken side2:\n====', side2, '===')
    return side1, side2
end

function ElementalObject:breakAlongNormal(contact)
    local nx, ny = contact:getNormal()
    local cx, cy = contact:getPositions() --Gets the first pos only.
    -- Generate another point to make a line
    local px = cx + nx - self.center.x
    local py = cy + ny - self.center.y
    self:centralize(self:computeCentroid())
    local seg = Seg(
    Point(cx - self.center.x, cy - self.center.y), Point(px, py))
    print('seg: '..tostring(seg))
    local normPoints = {}
    for i = 1, #self.points do
        print('self.points[i]: '..tostring(self.points[i]))
        local nextP
        if i == #self.points then
            nextP = self.points[1]
        else
            nextP = self.points[i + 1]
        end
        print('nextP: '..tostring(nextP))
        local eleSeg = Seg(self.points[i], nextP)
        local interPoint = eleSeg:getIntersectionAsLines(seg)
        print('interPoint: '..tostring(interPoint))
        if interPoint and eleSeg:hasPoint(interPoint) then
            table.insert(normPoints, interPoint)
        else
            print 'no'
        end
    end
    print('num of normPoints: '..#normPoints)
    return self:sortPointsIntoTwo(normPoints)
end

function ElementalObject:sortPointsIntoTwo(guidePoints)
    -- Sort points into two groups based on the guide.
    -- Points above and to the left get sorted into one group,
    -- the rest go into the other. Then, the guidePoints get added
    -- to both groups.
    if #guidePoints < 2 then
        return self.points
    end
    local guideSeg = Seg(guidePoints[1], guidePoints[2])
    local points1 = {}
    local points2 = {}
    for i = 1, #self.points do
        local result = guideSeg:findSidePointIsOn(self.points[i])
        if result > 0 then
            table.insert(points2, self.points[i])
        elseif result <= 0 then --TODO?
            table.insert(points1, self.points[i])
        end
    end
    for i = 1, #guidePoints do
        table.insert(points1, guidePoints[i])
        table.insert(points2, guidePoints[i])
    end
    print('num points1: '..#points1..' num points2: '..#points2)
    return points1, points2
end

function ElementalObject:endCollision(other, contact, world)

end

return ElementalObject
