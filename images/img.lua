local img = {}
function img.load(name)
    if img[name] then
        return img[name]
    end
    image = love.graphics.newImage(name)
    img[name] = image
    return image
end
return img
