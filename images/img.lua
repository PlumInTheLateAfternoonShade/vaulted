local img = {}
function img.load(name)
    if img[name] then
        return img[name]
    end
    local image = love.graphics.newImage("images/"..name)
    img[name] = image
    return image
end
return img
