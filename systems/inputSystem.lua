-- Handles input components.
local inputSystem = {}

require('systems.componentSystem'):inherit(inputSystem)

function inputSystem:keyPressed(key)
    for id, comp in pairs(self.components) do
        if comp.keyPresses[key] then
            comp.keyPresses[key]()
        end
    end
end

function inputSystem:keyReleased(key)
    for id, comp in pairs(self.components) do
        if comp.keyReleases[key] then
            comp.keyReleases[key]()
        end
    end
end

return inputSystem
