local Class = require 'class'
require 'utils'
require 'geometry.Point'
require 'lib.deepcopy.deepcopy'
local currPoints
-- Defines a textured image of a fire polygon.
local FireImage = Class
{
    name = 'FireImage',
    function(self, points, center)
        self.center = center
        self.points = points
        self.absPoints = table.deepcopy(points)
        self.right = tableMax(points, 'x')
        self.top = tableMin(points, 'y')
        self.bottom = tableMax(points, 'y')
        self.left = tableMin(points, 'x')
        self.width = self.right - self.left
        self.height = self.bottom - self.top
        self.imageData = love.image.newImageData(self.width, self.height)
        print('top: '..self.top)
        print('left: '..self.left)
        print('right: '..self.right)
        print('bottom: '..self.bottom)
        
        for i = 1, #self.absPoints do
            self.absPoints[i]:offset(-1*self.left, -1*self.top)
        end
        printTable('absPoints', self.absPoints)
        self:mapPixels()
        self.image = love.graphics.newImage(self.imageData)
    end
}

function FireImage:mapPixels()
    currPoints = self.absPoints
    self.imageData:mapPixel(self.pixelFunction)
end

function FireImage.pixelFunction(x, y, r, g, b, a)
    -- All points are white.
    r = 255
    g = 255
    b = 255
    -- Points outside the polygon are transparent.
    local p = Point(x, y)
    if not testPoint(p, currPoints) then
        a = 0
        --a = 50
    else
        a = 255
    end
    return r, g, b, a
end

return FireImage
