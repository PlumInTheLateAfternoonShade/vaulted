local Class = require 'class'

local VisibleIcons = Class
{
    name = 'VisibleIcons',
    function(self)
        self.iconList = {}
    end
}

function VisibleIcons:update()
    -- Remove any visible icons which have persisted beyond their lifetimes.
    for i = #self.iconList, 1, -1 do
        v = self.iconList[i]
        if os.clock() >= v.dateBorn + v.maxAge then
            table.remove(self.iconList, i)
        end
    end
end

function VisibleIcons:draw()
    -- Draw each visible icon
    for i = 1, #self.iconList do
        self.iconList[i]:draw()
    end
end

function VisibleIcons:add(icon)
    -- Add an icon to the list
    table.insert(self.iconList, icon)
end

return VisibleIcons
