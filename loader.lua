local lady = require 'lib.Lady.lady'

local loader = {}

function loader:pack(table)
    if table == nil then
        return
    end
    -- TODO delete
    table.mesh = nil
    table.body = nil
    table.fixture = nil
    local saveName = table.name..'.sav'
    lady.save_all(saveName, table)
    print('Saving '..saveName..' to '..love.filesystem.getSaveDirectory()..'.')
end

function loader:unpack(tableName)
    local saveName = tableName..'.sav'
    if love.filesystem.exists(saveName) then
        print(saveName..' exists, loading it.')
        return lady.load_all(saveName)
    end
    return nil
end

function loader:unpackIfExists(t)
    return self:unpack(t.name) or t
end

return loader
