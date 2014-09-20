local utils = require 'utils'
local Point = require 'geometry.Point'
local Seg = require 'geometry.Seg'
local Collider = require 'components.Collider'
local positionSystem = require 'systems.positionSystem'
local elementSystem = require 'systems.elementSystem'

-- Handles physics components.
local physicsSystem = {}

require('systems.componentSystem'):inherit(physicsSystem)

--TODO remove static fields
local objectFactory, entitySystem

function physicsSystem:init(w, objFact, eSys)
    self.world = w
    self.world:setSleepingAllowed(true)
    objectFactory = objFact
    entitySystem = eSys
    self.components = entitySystem.entities[Collider]
    self.destroyQueue = {}
end

function physicsSystem:delete(id)
    if self.components[id] then
        table.insert(self.destroyQueue, self.components[id].fixture)
    end
    self.components[id] = nil
end

function physicsSystem:getMass(id)
    local comp = self.components[id]
    if not comp or not comp.body then return 0 end
    return comp.body:getMass()
end

-- Remove all fixtures that have been flagged for deletion
function physicsSystem:clearDestroyQueue()
    for _, fixture in pairs(self.destroyQueue) do fixture:destroy() end
    self.destroyQueue = {}
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

local function initPolygonShape(id)
    local points = positionSystem:getPoints(id)
    removeRedundantPoints(points)
    centralize(points, computeCentroid(points))
    return love.physics.newPolygonShape(Point.pointsToCoords(points))
end

local function initCircleShape(id)
    return love.physics.newCircleShape(positionSystem:getRadius(id))
end

local function initFixture(comp)
    local fixture = love.physics.newFixture(comp.body, comp.shape)
    fixture:setFriction(comp.friction)
    fixture:setUserData(comp.id)
    return fixture
end

local shapeInits =
{
    polygon = initPolygonShape,
    circle = initCircleShape,
}

local function initShape(id)
    return shapeInits[positionSystem:getShape(id)](id)
end

local function updateComponent(comp, world, dt)
    if comp.firstUpdate then
        -- Need to construct here rather than constructor,
        -- in case construct occurs during middle of physics calcs.
        comp.firstUpdate = false
        comp.body = initBody(world, comp.type, comp.initV, positionSystem:getCenter(comp.id))
        comp.shape = initShape(comp.id)
        comp.fixture = initFixture(comp)
        -- Adjust stats if elemental object.
        local ele = elementSystem:get(comp.id)
        if ele then
            comp.fixture:setDensity(ele.density)
            comp.body:setGravityScale(ele.gravScale)
            comp.body:resetMassData()
        elseif comp.density then
            comp.fixture:setDensity(comp.density)
            comp.body:resetMassData()
        end
    end
    -- TODO refactor branching
    local shapeName = positionSystem:getShape(comp.id)
    if shapeName == 'polygon' then
        local centerX, centerY = comp.body:getWorldCenter()
        positionSystem:setPos(comp.id, centerX, centerY, {comp.body:getWorldPoints(comp.shape:getPoints())})
    elseif shapeName == 'circle' then
        local centerX, centerY = comp.body:getWorldCenter()
        positionSystem:setCenter(comp.id, centerX, centerY)
    end
    if comp.shouldBalance then
        local standupAccel = -250
        local angle = (comp.body:getAngle() % (math.pi * 2))
        if angle > math.pi then
            angle = angle - 2 * math.pi
        end
        if angle ~= 0 then
            local v = standupAccel*angle*dt
            comp.body:setAngularVelocity(v)
        end
    end
end

function physicsSystem:update(dt)
    self:clearDestroyQueue()
    for id, comp in pairs(self.components) do updateComponent(comp, self.world, dt) end
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
    objectFactory.createElemental(points, newCenter, elementSystem:get(id).name, newV)
end

function physicsSystem:handleBeginCollision(id, idOfCollider, contact)
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

local function wrappedIndex(length, index)
    return ((index - 1) % length) + 1
end

-- Return true if the closest point to the collision makes an angle < 30
-- degrees.
local function collidesAtSmallAngle(comp, colliderComp, contact)
    --[[local contactSeg = getContactSeg(contact, positionSystem:getCenter(comp.id))
    local function isCloserPointToSeg(point1, point2)
        return contactSeg:distToPointSquared(point1) >
        contactSeg:distToPointSquared(point2)
    end]]--
    local contactX, contactY, notOnSharpCorner = contact:getPositions()
    -- If we contacted at two points it probably shouldn't pierce
    if notOnSharpCorner then
        return false
    end
    local contactPoint = Point(contactX, contactY)
    local function isCloserPointToContact(point1, point2)
        return contactPoint:distanceSquared(point1) >
        contactPoint:distanceSquared(point2)
    end
    local points = positionSystem:getPoints(comp.id)
    local closestPoint, closestPointIndex =
        utils.tableCompareNoField(points, isCloserPointToContact)
    print("closestPoint: "..tostring(closestPoint).." contactPoint: "..tostring(contactPoint))

    --local closestPoint, closestPointIndex =
    --    utils.tableCompareNoField(points, isCloserPointToSeg)
    local beforePoint = points[wrappedIndex(#points, closestPointIndex - 1)]
    local afterPoint = points[wrappedIndex(#points, closestPointIndex + 1)]
    local veca = Point(closestPoint.x - beforePoint.x,
        closestPoint.y - beforePoint.y)
    local vecb = Point(closestPoint.x - afterPoint.x,
        closestPoint.y - afterPoint.y)
    -- Use inverted law of dot products to find angle
    local angle = math.acos(dot(veca, vecb) /
        (veca:magnitude() * vecb:magnitude()))
    print("angle is "..angle.." veca: "..tostring(veca).." vecb: "..tostring(vecb))
    return math.abs(angle) < math.pi / 6, closestPoint
end

-- Handles piercing
function physicsSystem:handlePostSolveCollision(id, idOfCollider, contact,
    normalImpulse, tangentImpulse1, colliderNormalImpulse,
    colliderTangentImpulse)
    --if not normalImpulse then print("nil normal") return end
    local comp = self.components[id]
    if not comp then return end
    local colliderComp = self.components[idOfCollider]
    if not colliderComp then return end
    -- Credit to http://www.iforce2d.net/b2dtut/sticky-projectiles for idea.
    if comp.shouldPierce then
        local isSharp, closestPoint = collidesAtSmallAngle(comp, colliderComp, contact)
        if isSharp then -- and colliderComp.hardness < normalImpulse then
            print("hardness: "..tostring(colliderComp.hardness).." impulse: "..tostring(normalImpulse))
            objectFactory.createWelder(id, idOfCollider,
                closestPoint, false)
        end
    end
end

function physicsSystem:beginCollision(aId, bId, coll)
    self:handleBeginCollision(aId, bId, coll)
    self:handleBeginCollision(bId, aId, coll)
end

function physicsSystem:endCollision(aId, bId, coll)

end

function physicsSystem:postSolveCollision(aId, bId, coll, normalImpulse1,
            tangentImpulse1, normalImpulse2, tangentImpulse2)
    self:handlePostSolveCollision(aId, bId, coll, normalImpulse1,
            tangentImpulse1, normalImpulse2, tangentImpulse2)
    self:handlePostSolveCollision(bId, aId, coll, normalImpulse2,
            tangentImpulse2, normalImpulse1, tangentImpulse1)
end

return physicsSystem
