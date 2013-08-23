require('TLTools.Tserial')
local loader = {}

function loader:pack(table)
    if table == nil then
        return
    end
    local saveName = table.name..'.sav'
    print('Saving '..saveName..' to '..love.filesystem.getSaveDirectory()..'.')
    love.filesystem.write(saveName, Tserial.pack(table, 
    function(data)
        return 'failed'
    end, true))
end

function loader:unpack(tableName)
    local saveName = tableName..'.sav'
    if love.filesystem.exists(saveName) then
        return Tserial.unpack(love.filesystem.read(saveName))
    end
    return nil
end

return loader
