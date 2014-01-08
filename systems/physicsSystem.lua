require 'lib.deepcopy.deepcopy'
local Point = require 'geometry.Point'
local positionSystem = require 'systems.positionSystem'

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
        end
        comp.center.x, comp.center.y = comp.body:getWorldCenter()
        if positionSystem[comp.id] then
            positionSystem.update(comp.id, comp.center, {comp.body:getWorldPoints(comp.shape:getPoints())})
        end
    end
end

--[[function CollidableObject:beginCollision(other, contact, world)
    --Update the temp as a weighted average.
    --This should really happen non-instantaneously and when things
    --are near each other, but this is good enough for now.
    if other.type == 'dynamic' and self.type == 'dynamic' then
        local m1 = self.body:getMass()
        local m2 = other.body:getMass()
        self.temp = (self.temp + (m1*self.temp + m2*other.temp)/(m1 + m2))/2
    end
end

function CollidableObject:endCollision(other, contact, world)
    --Do nothing special.
end]]--

return physicsSystem
