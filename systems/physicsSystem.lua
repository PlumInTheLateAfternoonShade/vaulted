require 'lib.deepcopy.deepcopy'
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local positionSystem = require 'systems.positionSystem'
local eleSystem = require 'systems.eleSystem'

-- Handles physics components.
local physicsSystem = {}

require('systems.componentSystem'):inherit(physicsSystem)

--TODO
local world, objectFactory, entitySystem

function physicsSystem:init(w, objFact, eSys)
    world = w
    objectFactory = objFact
    entitySystem = eSys
    self.components = {}
    self.destroyQueue = {}
end

function physicsSystem:delete(id)
    table.insert(self.destroyQueue, self.components[id].fixture)
    self.components[id] = nil
end

function physicsSystem:getMass(id)
    return self.components[id].body:getMass()
end

function physicsSystem:clearDestroyQueue()
    -- Remove all fixtures that have been flagged for deletion
    for _, fixture in pairs(self.destroyQueue) do fixture:destroy() end
    self.destroyQueue = {}
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

local function updateComponent(comp)
    if comp.firstUpdate then
        --Need to construct here rather than constructor,
        --in case construct occurs during middle of physics calcs.
        comp.firstUpdate = false
        removeRedundantPoints(comp.points)
        centralize(comp.points, computeCentroid(comp.points))
        comp.body = love.physics.newBody(world,
        comp.center.x, comp.center.y, comp.type)
        comp.body:setLinearVelocity(
        comp.initV.x, comp.initV.y)
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
        local ele = eleSystem:get(comp.id)
        if ele then
            comp.fixture:setDensity(ele.density)
            comp.body:setGravityScale(ele.gravScale)
            comp.body:resetMassData()
        end
    end
    comp.center.x, comp.center.y = comp.body:getWorldCenter()
    if positionSystem:get(comp.id) then
        positionSystem:update(comp.id, comp.center, {comp.body:getWorldPoints(comp.shape:getPoints())})
    end
end

function physicsSystem:update(dt)
    self:clearDestroyQueue()
    for id, comp in pairs(self.components) do updateComponent(comp) end
    world:update(dt)
end

local function getNewVelocity(comp, v, newCenter)
    local speed = v:magnitude()
    local newV = Seg(comp.center, newCenter):normalize()
    newV:scale(speed)
    return newV
end

local function getContactSeg(contact, center)
    local cx, cy = contact:getPositions() --Gets the first pos only.
    -- Generate another point to make a line
    local c = Point(cx, cy)
    local p = c:getReflectAcrossPoint(center)
    c:offset(-center.x, -center.y)
    p:offset(-center.x, -center.y)
    return Seg(c, p)
end

local function breakNearSeg(points, center, seg)
    -- Finds the two points closest to the seg's endpoints
    -- and returns two collections of points on either side.
    print('breaking near seg '..tostring(seg))
    printTable('points:\n====', points, '===')
    -- Move points around their center.
    local ps = objectDeepcopy(points)
    --for i = 1, #ps do ps[i] = ps[i] + center end
    printTable('centered points:', ps)
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
        return {p0 + center, ps[1] + center, mP + center}, {p0 + center, ps[2] + center, mP + center}
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
    for i = 1, #side1 do side1[i] = side1[i] + center end
    for i = 1, #side2 do side2[i] = side2[i] + center end
    return side1, side2
end

function physicsSystem:handleCollision(id, contact)
    local comp = self.components[id]
    if not comp then return end
    if comp.breakable and comp.body:getMass() > comp.maxMassToBreak then
        centralize(comp.points, computeCentroid(comp.points))
        local conSeg = getContactSeg(contact, comp.center)
        local points1, points2 = breakNearSeg(comp.points, comp.center, conSeg)
        if points1 and points2 and #points1 > 2 and #points2 > 2 then
            -- Order the points so they form a valid convex polygon.
            points1 = convexHull(points1)
            points2 = convexHull(points2)
            
            -- Compute their new center points.
            local newCenter1 =
            computeCentroid(points1) --+ comp.center Not needed because we add
            local newCenter2 = 
            computeCentroid(points2) --+ comp.center

            -- Debug prints
            print('area1: '..computeArea(points1))
            printTable('points1: ', points1)
            print('area2: '..computeArea(points2))
            printTable('points2: ', points2)
            
            -- Assign their velocities
            local v = Point(comp.body:getLinearVelocity())
            local newV1 = getNewVelocity(comp, v, newCenter1)
            local newV2 = getNewVelocity(comp, v, newCenter2)

            -- Construct the elemental objects.
            objectFactory.createElemental(points1, newCenter1, eleSystem:get(id).name, newV1)
            objectFactory.createElemental(points2, newCenter2, eleSystem:get(id).name, newV2)

            -- Delete the old entitiy
            entitySystem:delete(id)
        end
    end
end

function physicsSystem:beginCollision(aId, bId, coll)
    self:handleCollision(aId, coll)
    self:handleCollision(bId, coll)
end

function physicsSystem:endCollision(aId, bId, coll)

end

return physicsSystem
