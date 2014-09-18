local lady = require 'lib.Lady.lady'
local Component = require 'components.Component'

local loader = {}

function loader:pack(table)
    if table == nil then
        return
    end
    local saveName = table.name..'.sav'
    lady.save_all(saveName, table)
    print('Saving '..saveName..' to '..love.filesystem.getSaveDirectory()..'.')
end

function loader:unpack(tableName)
    local saveName = tableName..'.sav'
    if love.filesystem.exists(saveName) then
        print(saveName..' exists, loading it.')
        local loaded = lady.load_all(saveName)
        if loaded.static and loaded.static:isSubclassOf(Component) then
            loaded.systems = require('component'..loaded.class).class.static.systems
        end
    end
    return nil
end

function loader:unpackIfExists(t)
    return self:unpack(t.name) or t
end

return loader
