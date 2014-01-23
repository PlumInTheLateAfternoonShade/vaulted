local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local positionSystem = require 'systems.positionSystem'
local eleSystem = require 'systems.eleSystem'

-- Handles body components.
local bodySystem = {}

require('systems.componentSystem'):inherit(bodySystem)

--TODO remove static fields
local objectFactory, entitySystem

function bodySystem:init(w, objFact, eSys)
    self.world = w
    self.world:setSleepingAllowed(true)
    objectFactory = objFact
    entitySystem = eSys
    self.components = {}
    self.addQueue = {}
end

function bodySystem:getMass(id)
    local comp = self.components[id]
    if not comp or not comp.body then return 0 end
    return comp.body:getMass()
end

local function centralize(points, c)
    for i = 1, #points do
        points[i] = points[i] - c
    end
end

local function initBody(world, type, initV, center)
    local body = love.physics.newBody(world,
    center.x, center.y, type)
    body:setLinearVelocity(
    initV.x, initV.y)
    return body
end

function bodySystem:update(dt)
    if #self.addQueue > 0 then
        for id, comp in pairs(self.addQueue) do
            comp.body = initBody(world, comp.type, comp.initV, positionSystem:getCenter(comp.id))
            -- Adjust stats if elemental object.
            local ele = eleSystem:get(comp.id)
            if ele then
                comp.body:setGravityScale(ele.gravScale)
                comp.body:resetMassData()
            end
            self.components[id] = comp
        end
        self.addQueue = {}
    end
    self.world:update(dt)
end

local function getNewVelocity(v, center, newCenter)
    local speed = v:magnitude()
    local newV = Seg(center, newCenter):normalize()
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

local function makeElementalObjectFromPoints(id, points, center, v)
    -- Order the points so they form a valid convex polygon.
    points = convexHull(points)
    -- Compute the new center point.
    local newCenter = computeCentroid(points)
    -- Assign the velocity
    local newV = getNewVelocity(v, center, newCenter)
    -- Construct the elemental object.
    objectFactory.createElemental(points, newCenter, eleSystem:get(id).name, newV)
end

function bodySystem:handleCollision(id, contact)
    local comp = self.components[id]
    if not comp then return end
    if comp.breakable and comp.body:getMass() > comp.maxMassToBreak then
        local points, center = positionSystem:getPoints(id), positionSystem:getCenter(id)
        centralize(points, computeCentroid(points))
        local conSeg = getContactSeg(contact, center)
        local points1, points2 = breakNearSeg(points, center, conSeg)
        if points1 and points2 and #points1 > 2 and #points2 > 2 then
            local v = Point(comp.body:getLinearVelocity())
            -- Make the new entities
            makeElementalObjectFromPoints(id, points1, center, v)
            makeElementalObjectFromPoints(id, points2, center, v)
            -- Delete the old entitiy
            entitySystem:delete(id)
        end
    end
end

function bodySystem:beginCollision(aId, bId, coll)
    self:handleCollision(aId, coll)
    self:handleCollision(bId, coll)
end

function bodySystem:endCollision(aId, bId, coll)

end

return bodySystem
