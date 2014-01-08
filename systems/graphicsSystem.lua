local Point = require('geometry.Point')
local positionSystem = require('systems.positionSystem')
local img = require('images.img')

-- System for rendering graphics
local graphicsSystem = {}

local meshes = {}
local polygons = {}

function graphicsSystem.addMesh(comp)
    meshes[comp.id] = comp
end

function graphicsSystem.addPolygon(comp)
    polygons[comp.id] = comp
end

local function drawPolygons()
    for id, comp in pairs(polygons) do
        setColor(comp.color)
        love.graphics.polygon("fill", unpack(positionSystem[id].coords))
    end
end

local function computeTextureCoords(comp)
    local points = positionSystem.getPoints(comp.id)
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
    local textureCoords = computeTextureCoords(comp, coords)
    local wPoints = positionSystem.getCoords(comp.id)
    
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
    setColor(comp.color)
    comp.mesh:setVertices(getMeshVertices(comp))
    love.graphics.draw(comp.mesh, 0, 0)
end

local function drawMeshes()
    for id, comp in pairs(meshes) do
        if comp.needsInit then
            comp.needsInit = false
            initMesh(comp)
        end
        drawMesh(comp)
    end
end

function graphicsSystem.draw()
    drawPolygons()
    drawMeshes()
end

return graphicsSystem
