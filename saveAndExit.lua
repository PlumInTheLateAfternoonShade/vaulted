local loader = require('loader')
if ShouldProfile then
    ProFi = require 'ProFi'
end
local SaveAndExit = {}

function SaveAndExit:close()
    loader:pack(hero)
    loader:pack(conf)
    if ShouldProfile then
        -- prof only
        print('Stopping profiler.')
        ProFi:stop()
        ProFi:writeReport('profile.txt')
    end
    os.exit()
end

return SaveAndExit
