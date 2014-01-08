require 'lib.deepcopy.deepcopy'
local Point = require 'geometry.Point'
local positionSystem = require 'systems.positionSystem'
local eleSystem = require 'systems.eleSystem'

-- Handles physics components.
local physicsSystem = {}

local components = {}

--TODO
local world

function physicsSystem.init(w)
    world = w
end

function physicsSystem.add(comp)
    components[comp.id] = comp
end

local function centralize(points, c)
    for i = 1, #points do
        points[i] = points[i] - c
    end
end

local function translateCoordsToPoints(comp)
    local coords = {comp.body:getWorldPoints(comp.shape:getPoints())}
    comp.points = {}
    for i = 1, #coords, 2 do
        table.insert(comp.points, Point(coords[i], coords[i + 1]))
    end
end

function physicsSystem.update(dt)
    for i = #components, 1, -1 do
        local comp = components[i]
        if comp.firstUpdate then
            --Need to construct here rather than constructor,
            --in case construct occurs during middle of physics calcs.
            comp.firstUpdate = false
            removeRedundantPoints(comp.points)
            centralize(comp.points, computeCentroid(comp.points))
            comp.body = love.physics.newBody(world,
            comp.center.x, comp.center.y, comp.type)
            --This is perhaps the ugliest thing I've ever written.
            --There must be a clever way to do it with unpack.
            --Or maybe a function in Point that returns x, y?
            local a, b, c, d, e, f, g, h = unpack(comp.points)
            if h then
                comp.shape = love.physics.newPolygonShape(a.x, a.y, 
                b.x, b.y, c.x,
                c.y, d.x, d.y, e.x, e.y, f.x, f.y, g.x, g.y, h.x, h.y)
            elseif g then
                comp.shape = love.physics.newPolygonShape(a.x, a.y, 
                b.x, b.y, c.x,
                c.y, d.x, d.y, e.x, e.y, f.x, f.y, g.x, g.y)
            elseif f then
                comp.shape = love.physics.newPolygonShape(a.x, a.y, 
                b.x, b.y, c.x,
                c.y, d.x, d.y, e.x, e.y, f.x, f.y)
            elseif e then
                comp.shape = love.physics.newPolygonShape(a.x, a.y, 
                b.x, b.y, c.x,
                c.y, d.x, d.y, e.x, e.y)
            elseif d then
                comp.shape = love.physics.newPolygonShape(a.x, a.y, 
                b.x, b.y, c.x,
                c.y, d.x, d.y)
            else
                comp.shape = love.physics.newPolygonShape(a.x, a.y, 
                b.x, b.y, c.x,
                c.y)
            end
            comp.fixture = love.physics.newFixture(comp.body, comp.shape)
            comp.fixture:setFriction(comp.friction)
            comp.fixture:setUserData(comp.id)
            local ele = eleSystem.get(comp.id)
            if ele then
                comp.fixture:setDensity(ele.density)
                comp.body:setGravityScale(ele.gravScale)
                comp.body:resetMassData()
            end
        end
        comp.center.x, comp.center.y = comp.body:getWorldCenter()
        if positionSystem[comp.id] then
            positionSystem.update(comp.id, comp.center, {comp.body:getWorldPoints(comp.shape:getPoints())})
        end
    end
end
--[[
function ElementalObject:beginCollision(other, contact, world)
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
end]]--

local function handleCollision(id, coll)
    local comp = components[id]
    if comp.breakable and comp.body:getMass() > comp.maxMassToBreak then
        centralize(comp.points, computeCentroid(comp.points))
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
    end
    if deleteSeconds then
        print('Deleting in '..deleteSeconds..'.')
        self:setDeleteTime(deleteSeconds)
    end
end

function physicsSystem.beginCollision(aId, bId, coll)
    handleCollision(aId, coll)
    handleCollision(bId, coll)
end

function physicsSystem.endCollision(aId, bId, coll)

end

return physicsSystem
