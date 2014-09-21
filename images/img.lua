local utils = require 'utils'
local img = {}

function img.load(name)
    if img[name] then
        return img[name]
    end
    local image = love.graphics.newImage("images/"..name)
    img[name] = image
    return image
end

utils.mapOnAllFiles('images', img.load, {'%.gif', '%.png', '%.jpg'})

return img
