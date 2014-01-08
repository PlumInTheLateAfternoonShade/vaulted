-- Handles ele components.
local eleSystem = {}

function eleSystem.add(comp)
    eleSystem[comp.id] = comp
end

function eleSystem.get(id)
    return eleSystem[id]
end

function eleSystem.update(dt)
end

return eleSystem
