local Point = require('geometry.Point')
local positionSystem = require('systems.positionSystem')
local temperatureSystem = require('systems.temperatureSystem')
local img = require('images.img')
local MeshRenderer = require 'components.MeshRenderer'
local ShapeRenderer = require 'components.ShapeRenderer'
local StatBar = require 'components.StatBar'

-- System for rendering graphics
local graphicsSystem = {}

function graphicsSystem:init(cam, map, entities)
    self.camera = cam
    self.map = map
    self.meshes = entities[MeshRenderer]
    self.shapes = entities[ShapeRenderer]
    self.statBars = entities[StatBar]
    self.background = img.load('bg4.png')
end

function graphicsSystem:delete(id)
    self.shapes[id] = nil
    self.meshes[id] = nil
    self.statBars[id] = nil
end

local function setToComponentColor(comp)
    setColor(temperatureSystem:getAdjustedColor(comp.id, comp.color))
end

local drawShape =
{
    circle = function(id)
        local center = positionSystem:getCenter(id)
        love.graphics.circle("fill", center.x, center.y, positionSystem:getRadius(id), 30)
    end,
    polygon = function(id)
        love.graphics.polygon("fill", unpack(positionSystem:getCoords(id)))
    end,
}

local function drawShapes(shapes, raw)
    for id, comp in pairs(shapes) do
        if not raw or comp.shouldPreview then
            setToComponentColor(comp)
            drawShape[positionSystem:getShape(id)](id)
        end
    end
end

local function computeTextureCoords(comp)
    local points = positionSystem:getPoints(comp.id)
    local maxY = tableMax(points, 'y')
    local minY = tableMin(points, 'y')
    local maxX = tableMax(points, 'x')
    local minX = tableMin(points, 'x')
    local scaleFactor = math.max(maxY - minY, maxX - minX)
    local textureCoords = {}
    for i = 1, #points do
        table.insert(textureCoords,
            (points[i].x - minX) / scaleFactor)
        table.insert(textureCoords,
            (points[i].y - minY) / scaleFactor)
    end
    return textureCoords
end

local function getMeshVertices(comp)
    local textureCoords = computeTextureCoords(comp)
    local wPoints = positionSystem:getCoords(comp.id)
    local vertices = {}
    for i = 1, #wPoints, 2 do
        table.insert(vertices,
        {
            wPoints[i], -- x coord
            wPoints[i + 1], -- y coord
            textureCoords[i],
            textureCoords[i + 1]
        })
    end
    return vertices
end

local function initMesh(comp)
    comp.mesh = love.graphics.newMesh(getMeshVertices(comp), img.load(comp.imageName))
end

local function drawMesh(comp)
    setToComponentColor(comp)
    comp.mesh:setVertices(getMeshVertices(comp))
    love.graphics.draw(comp.mesh, 0, 0)
    -- TESTING
    local cen = positionSystem:get(comp.id).center
    setColor({r = 255, g = 0, b = 200})
    love.graphics.circle("fill", cen.x, cen.y, 5, 10)
    setColor({r = 255, g = 200, b = 0})
    each(function(p) love.graphics.circle("fill", p.x, p.y, 5, 10) end, positionSystem:getPoints(comp.id))
end

local function drawMeshes(meshes, raw)
    for id, comp in pairs(meshes) do
        if comp.firstUpdate then
            comp.firstUpdate = false
            initMesh(comp)
        end
        if not raw or comp.shouldPreview then
            drawMesh(comp)
        end
    end
end

local function drawStatBars(statBars)
    for id, comp in pairs(statBars) do
        setColor(comp.color)
        love.graphics.rectangle("fill", 0, conf.screenHeight*comp.topPercent,
        conf.screenWidth*comp.getPercent(), conf.screenHeight*comp.heightPercent)
    end
end

function graphicsSystem:drawRawComponents(raw)
    drawShapes(self.shapes, raw)
    drawMeshes(self.meshes, raw)
end


function graphicsSystem:drawMap()
    -- set the tile map's draw range so we only draw the tiles on screen
    self.map:setDrawRange(self.camera.x, self.camera.y, conf.screenWidth, conf.screenHeight)
    -- draw the tile map
    self.map:draw()
end

function graphicsSystem:drawUI()
    drawStatBars(self.statBars)
end

function graphicsSystem:drawBackground()
    love.graphics.draw(self.background, 0, 0)
end

function graphicsSystem:update(dt)
    local heroCenter = positionSystem:getCenter(heroId)
    self.camera:setAdjPosition(heroCenter.x, heroCenter.y, dt)
end

return graphicsSystem
